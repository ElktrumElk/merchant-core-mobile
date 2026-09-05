import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:first_flutter_project/network/authentication/user_authentication.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart' hide Mac;

class _ChatKeyData {
  final BigInt modulus;
  final BigInt privateExponent;
  final BigInt p;
  final BigInt q;
  final String publicKeyPem;

  const _ChatKeyData({
    required this.modulus,
    required this.privateExponent,
    required this.p,
    required this.q,
    required this.publicKeyPem,
  });

  Map<String, String> toJson() => {
        'modulus': _bigIntToBase64(modulus),
        'privateExponent': _bigIntToBase64(privateExponent),
        'p': _bigIntToBase64(p),
        'q': _bigIntToBase64(q),
        'publicKeyPem': publicKeyPem,
      };

  factory _ChatKeyData.fromJson(Map<String, dynamic> json) => _ChatKeyData(
        modulus: _bigIntFromBase64(json['modulus'] as String),
        privateExponent: _bigIntFromBase64(json['privateExponent'] as String),
        p: _bigIntFromBase64(json['p'] as String),
        q: _bigIntFromBase64(json['q'] as String),
        publicKeyPem: json['publicKeyPem'] as String,
      );
}

String _bigIntToBase64(BigInt value) => base64Encode(_bigIntToBytes(value));

BigInt _bigIntFromBase64(String value) => _bytesToBigInt(base64Decode(value));

Uint8List _bigIntToBytes(BigInt value) {
  final hex = value.toRadixString(16);
  final padded = hex.length.isOdd ? '0$hex' : hex;
  final bytes = Uint8List(padded.length ~/ 2);
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] = int.parse(padded.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return bytes;
}

BigInt _bytesToBigInt(List<int> bytes) {
  var value = BigInt.zero;
  for (final byte in bytes) {
    value = (value << 8) | BigInt.from(byte);
  }
  return value;
}

List<int> _derLength(int length) {
  if (length < 0x80) return [length];
  final hex = length.toRadixString(16);
  final padded = hex.length.isOdd ? '0$hex' : hex;
  final bytes = <int>[];
  for (var i = 0; i < padded.length; i += 2) {
    bytes.add(int.parse(padded.substring(i, i + 2), radix: 16));
  }
  return [0x80 | bytes.length, ...bytes];
}

List<int> _derElement(int tag, List<int> content) =>
    [tag, ..._derLength(content.length), ...content];

List<int> _derInteger(BigInt value) {
  var bytes = _bigIntToBytes(value);
  if (bytes.isEmpty) bytes = Uint8List.fromList([0]);
  if ((bytes[0] & 0x80) != 0) {
    bytes = Uint8List.fromList([0, ...bytes]);
  }
  return _derElement(0x02, bytes);
}

List<int> _rsaPublicKeyDer(BigInt modulus, BigInt exponent) =>
    _derElement(0x30, [..._derInteger(modulus), ..._derInteger(exponent)]);

const List<int> _rsaEncryptionOid = [
  0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01,
];

List<int> _subjectPublicKeyInfoDer(BigInt modulus, BigInt exponent) {
  final algorithm = _derElement(0x30, [..._rsaEncryptionOid, 0x05, 0x00]);
  final subjectPublicKey =
      _derElement(0x03, [0x00, ..._rsaPublicKeyDer(modulus, exponent)]);
  return _derElement(0x30, [...algorithm, ...subjectPublicKey]);
}

String _rsaPublicKeyPem(BigInt modulus, BigInt exponent) {
  final b64 = base64Encode(_subjectPublicKeyInfoDer(modulus, exponent));
  final buffer = StringBuffer('-----BEGIN PUBLIC KEY-----\n');
  for (var i = 0; i < b64.length; i += 64) {
    buffer.writeln(
        b64.substring(i, i + 64 > b64.length ? b64.length : i + 64));
  }
  buffer.write('-----END PUBLIC KEY-----');
  return buffer.toString();
}

Future<_ChatKeyData> _generateChatKeypair() {
  return Isolate.run(() {
    final rng = Random.secure();
    final seed =
        Uint8List.fromList(List<int>.generate(32, (_) => rng.nextInt(256)));
    final random = FortunaRandom()..seed(KeyParameter(seed));

    final generator = KeyGenerator('RSA')
      ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 12),
        random,
      ));

    final pair = generator.generateKeyPair();
    final publicKey = pair.publicKey as RSAPublicKey;
    final privateKey = pair.privateKey as RSAPrivateKey;

    final n = publicKey.modulus!;
    final e = publicKey.publicExponent!;

    return _ChatKeyData(
      modulus: n,
      privateExponent: privateKey.privateExponent!,
      p: privateKey.p!,
      q: privateKey.q!,
      publicKeyPem: _rsaPublicKeyPem(n, e),
    );
  });
}

class ChatService {
  final String _base = SecreteData.authUrl;
  final _storage = const FlutterSecureStorage();

  static const _kPrivateKey = 'chat_private_key';
  static const zeroKeyB64 = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';

  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final AesGcm _aesGcm = AesGcm.with256bits();

  String? _participantKey;
  _ChatKeyData? _keyData;
  final Map<String, String> _threadKeyCache = {};

  Future<String> initChatEncryption() async {
    final participantKey = await _resolveParticipantKey();
    final keyData = await _loadOrCreateKeyData();
    await _registerKeyIfNeeded(participantKey, keyData.publicKeyPem);
    return participantKey;
  }

  Future<String> _resolveParticipantKey() async {
    if (_participantKey != null) return _participantKey!;

    final token = await TokenStorage.loadToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }

    final url = Uri.parse('$_base${SecreteData.getUserInfoEndpoint}');
    final resp = await http.get(url, headers: SecreteData(token).getHeaders());
    if (resp.statusCode != 200) {
      throw Exception('Failed to resolve chat participant');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final id = data['id'];
    if (id == null) {
      throw Exception('Could not determine chat participant');
    }

    _participantKey = 'user:$id';
    return _participantKey!;
  }

  Future<_ChatKeyData> _loadOrCreateKeyData() async {
    if (_keyData != null) return _keyData!;

    final saved = await _storage.read(key: _kPrivateKey);
    if (saved != null && saved.isNotEmpty) {
      try {
        final data =
            _ChatKeyData.fromJson(jsonDecode(saved) as Map<String, dynamic>);
        _keyData = data;
        return data;
      } catch (_) {
        await _storage.delete(key: _kPrivateKey);
      }
    }

    debugPrint('Generating new chat encryption keypair...');
    final data = await _generateChatKeypair();
    await _storage.write(key: _kPrivateKey, value: jsonEncode(data.toJson()));
    _keyData = data;
    return data;
  }

  Future<void> _registerKeyIfNeeded(
      String participantKey, String publicKeyPem) async {
    final token = await TokenStorage.loadToken();
    final keyUrl = Uri.parse('$_base/api/v1/chat/keys/$participantKey');
    try {
      final resp = await http.get(keyUrl, headers: SecreteData(token).getHeaders());
      if (resp.statusCode == 200) {
        final existing = ((jsonDecode(resp.body) as Map<String, dynamic>)[
            'public_key_pem'] ??
            '')
            .toString()
            .trim();
        if (existing == publicKeyPem.trim()) return;
      }
    } catch (_) {}

    final url = Uri.parse('$_base/api/v1/chat/keys');
    final resp = await http.post(
      url,
      headers: SecreteData(token).getHeaders(),
      body: jsonEncode({'public_key_pem': publicKeyPem}),
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to register chat key: ${resp.body}');
    }
  }

  Future<String> resolveThreadKey(Map<String, dynamic>? thread) async {
    if (thread == null) {
      throw Exception('Thread data not available');
    }
    final threadId = thread['id'];
    if (threadId is String && _threadKeyCache.containsKey(threadId)) {
      return _threadKeyCache[threadId]!;
    }

    final participantKey = await _resolveParticipantKey();
    final wrapped = participantKey.startsWith('org:')
        ? (thread['thread_key_wrapped_owner'] as String? ?? '')
        : (thread['thread_key_wrapped_buyer'] as String? ?? '');
    if (wrapped.isEmpty) {
      throw Exception('Thread key not available for this participant');
    }

    final keyData = await _loadOrCreateKeyData();
    final unwrapped = _unwrapRsaOaep(keyData, wrapped);
    if (threadId is String) {
      _threadKeyCache[threadId] = unwrapped;
    }
    return unwrapped;
  }

  String _unwrapRsaOaep(_ChatKeyData keyData, String wrappedB64) {
    final privateKey = RSAPrivateKey(
      keyData.modulus,
      keyData.privateExponent,
      keyData.p,
      keyData.q,
    );
    final cipher = OAEPEncoding.withSHA256(RSAEngine())
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));
    final plain = cipher.process(base64Decode(wrappedB64));
    return base64Encode(plain);
  }

  Future<String> decryptPayload(
      String threadKeyB64, String ciphertextB64, String ivB64) async {
    final ciphertext = base64Decode(ciphertextB64);
    if (ciphertext.length < 16) {
      throw Exception('Invalid ciphertext');
    }
    final mac = Mac(ciphertext.sublist(ciphertext.length - 16));
    final body = ciphertext.sublist(0, ciphertext.length - 16);
    final clear = await _aesGcm.decrypt(
      SecretBox(body, nonce: base64Decode(ivB64), mac: mac),
      secretKey: SecretKey(base64Decode(threadKeyB64)),
    );
    return utf8.decode(clear);
  }

  Future<void> sendMessage(
    String threadId,
    String text, {
    Map<String, dynamic>? thread,
  }) async {
    final threadKey = await resolveThreadKey(thread);
    final token = await TokenStorage.loadToken();
    final url = Uri.parse('$_base/api/v1/chat/threads/$threadId/messages');

    final response = await http.post(
      url,
      headers: SecreteData(token).getHeaders(),
      body: jsonEncode({
        "text": text,
        "thread_key": threadKey,
        "message-type": "text",
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send message: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getThreads() async {
    await initChatEncryption();
    final token = await TokenStorage.loadToken();
    final url = Uri.parse('$_base/api/v1/chat/threads');

    final response = await http.get(
      url,
      headers: SecreteData(token).getHeaders(),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(body['threads'] ?? []);
    } else {
      throw Exception('Failed to load chat threads');
    }
  }

  Future<Map<String, dynamic>> getMessages(String threadId) async {
    final token = await TokenStorage.loadToken();
    final url = Uri.parse('$_base/api/v1/chat/threads/$threadId/messages');

    final response = await http.get(
      url,
      headers: SecreteData(token).getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<void> createThread(
      String shopId, String shopName, String ownerKey) async {
    await initChatEncryption();
    final token = await TokenStorage.loadToken();
    final url = Uri.parse('$_base/api/v1/chat/threads');

    final response = await http.post(
      url,
      headers: SecreteData(token).getHeaders(),
      body: jsonEncode({
        "shop_id": shopId,
        "shop_name": shopName,
        "owner_key": ownerKey,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to start chat thread: ${response.body}');
    }
  }

  Future<void> deleteThread(String threadId) async {
    final token = await TokenStorage.loadToken();
    final url = Uri.parse('$_base/api/v1/chat/threads/$threadId');
    final response = await http.delete(
      url,
      headers: SecreteData(token).getHeaders(),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete thread: ${response.body}');
    }
  }

  Future<void> wipeKeys() async {
    _participantKey = null;
    _keyData = null;
    _threadKeyCache.clear();
    await _storage.delete(key: _kPrivateKey);
  }
}