import 'dart:async';
import 'package:first_flutter_project/network/chat_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatThreadScreen extends StatefulWidget {
  final Map<String, dynamic> thread;
  const ChatThreadScreen({super.key, required this.thread});

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  Map<String, dynamic>? _thread;
  List<Map<String, dynamic>> _messages = [];
  final List<Map<String, dynamic>> _locals = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _thread = widget.thread;
    _prepare();
    _startPolling();
  }

  Future<void> _prepare() async {
    try {
      await _chatService.initChatEncryption();
    } catch (_) {}
    await _fetchMessages();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchMessages(isBackground: true);
    });
  }

  Future<void> _fetchMessages({bool isBackground = false}) async {
    try {
      final response = await _chatService.getMessages(widget.thread['id']);
      final thread = response['thread'] as Map<String, dynamic>? ?? _thread;
      final messages = List<Map<String, dynamic>>.from(response['messages'] ?? []);

      String threadKey = '';
      if (thread != null) {
        try {
          threadKey = await _chatService.resolveThreadKey(thread);
        } catch (_) {}
      }

      final decrypted = <Map<String, dynamic>>[];
      for (final message in messages) {
        final copy = Map<String, dynamic>.from(message);
        copy['decrypted_text'] = await _decryptMessage(threadKey, message);
        decrypted.add(copy);
      }

      if (mounted) {
        setState(() {
          _thread = thread;
          // Display messages from top to bottom (chronological)
          _messages = decrypted;
          _isLoading = false;
        });
        // If we want it to look like WhatsApp (newest at bottom), 
        // we scroll to the end of the list.
        if (!isBackground) _scrollToBottom();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String> _decryptMessage(
      String threadKey, Map<String, dynamic> message) async {
    final ciphertext = message['ciphertext'] as String? ?? '';
    final iv = message['iv'] as String? ?? '';
    if (ciphertext.isEmpty) return '';

    if (threadKey.isNotEmpty) {
      try {
        return await _chatService.decryptPayload(threadKey, ciphertext, iv);
      } catch (_) {}
    }
    if (kDebugMode) {
      try {
        return await _chatService.decryptPayload(
            ChatService.zeroKeyB64, ciphertext, iv);
      } catch (_) {}
    }
    return 'Encrypted';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;

    _messageCtrl.clear();

    final local = <String, dynamic>{
      'id': 'local-${DateTime.now().microsecondsSinceEpoch}',
      '_local': true,
      'sender_key': 'user:local',
      'decrypted_text': text,
      'sent_at': DateTime.now().toIso8601String(),
      '_status': 'sending',
    };
    setState(() => _locals.add(local));
    _scrollToBottom();

    try {
      await _chatService.sendMessage(
        widget.thread['id'],
        text,
        thread: _thread ?? widget.thread,
      );
      if (!mounted) return;
      setState(() => _locals.remove(local));
      _fetchMessages();
    } catch (e) {
      if (!mounted) return;
      setState(() => local['_status'] = 'failed');
      _scrollToBottom();
    }
  }

  Future<void> _retrySend(Map<String, dynamic> local) async {
    final text = (local['decrypted_text'] as String? ?? '').trim();
    if (text.isEmpty) return;
    setState(() => local['_status'] = 'sending');
    try {
      await _chatService.sendMessage(
        widget.thread['id'],
        text,
        thread: _thread ?? widget.thread,
      );
      if (!mounted) return;
      setState(() => _locals.remove(local));
      _fetchMessages();
    } catch (e) {
      if (!mounted) return;
      setState(() => local['_status'] = 'failed');
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              foregroundImage:
                  (widget.thread['shop_image'] != null &&
                          (widget.thread['shop_image'] as String).isNotEmpty)
                      ? NetworkImage(widget.thread['shop_image'] as String)
                      : null,
              onForegroundImageError: widget.thread['shop_image'] != null
                  ? (_, _) {}
                  : null,
              child: const Icon(Icons.store),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.thread['shop_name'] ?? 'Official Store',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Text('Online', style: TextStyle(color: Colors.green, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + _locals.length,
                  itemBuilder: (context, index) {
                    if (index < _messages.length) {
                      return _buildMessageBubble(_messages[index]);
                    }
                    return _buildMessageBubble(_locals[index - _messages.length]);
                  },
                ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLocal = message['_local'] == true;
    final senderKey = message['sender_key'] as String? ?? '';
    final isMe = isLocal || senderKey.startsWith('user:');
    final status = message['_status'] as String? ?? '';
    final createdAt = message['sent_at'] as String? ?? DateTime.now().toIso8601String();
    String timeStr = '';
    try {
      timeStr = DateFormat.jm().format(DateTime.parse(createdAt));
    } catch (_) {}

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe
              ? (isDark ? const Color(0xFF1E3A34) : const Color(0xFFD9FDD3))
              : theme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 12),
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor(theme, isDark),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message['decrypted_text'] ?? '',
              style: TextStyle(fontSize: 15, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 4),
            if (status == 'failed') ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 16, color: Colors.redAccent),
                  TextButton(
                    onPressed: isLocal ? () => _retrySend(message) : null,
                    child: const Text('Retry'),
                  ),
                ],
              ),
              const SizedBox(height: 2),
            ],
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                ),
                if (isLocal && status == 'sending') ...[
                  const SizedBox(width: 6),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ] else if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.done_all, size: 14, color: theme.colorScheme.primary),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color shadowColor(ThemeData theme, bool isDark) {
    return isDark
        ? theme.shadowColor.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.08);
  }

  Widget _buildMessageInput() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
      color: theme.cardColor,
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.add, color: theme.colorScheme.primary),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageCtrl,
                decoration: const InputDecoration(
                  hintText: 'Message',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: IconButton(
              icon: Icon(Icons.send, color: theme.colorScheme.onPrimary, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
