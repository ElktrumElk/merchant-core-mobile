import 'dart:async';
import 'package:first_flutter_project/components/cart/cart_bottom_sheet.dart';
import 'package:first_flutter_project/global/market_cart.dart';
import 'package:first_flutter_project/network/chat_service.dart';
import 'package:first_flutter_project/pages/market/market_shop_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Premium near-black used for the send button and discount order button on the
/// light theme, matching the app's dark-onSurface accent.
const Color _premiumBlack = Color(0xFF0A0A0A);

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
  bool _isOrg = false;
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
      _isOrg = (_chatService.participantKey ?? '').startsWith('org:');
    } catch (_) {}
    _chatService.markThreadRead(widget.thread['id']);
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
      final messages = List<Map<String, dynamic>>.from(
        response['messages'] ?? [],
      );
      final serverIds = messages.map((m) => m['id']).toSet();

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
          // Drop local bubbles whose send was confirmed by the server in the
          // same rebuild so the sent message swaps in seamlessly (no flicker).
          _locals.removeWhere((l) => serverIds.contains(l['id']));
          _thread = thread;
          // Display messages from top to bottom (chronological)
          _messages = decrypted;
          _isLoading = false;
        });
        // If we want it to look like WhatsApp (newest at bottom),
        // we scroll to the end of the list.
        if (!isBackground) _scrollToBottom();
      }
      if (decrypted.isNotEmpty) {
        final last = decrypted.last;
        await _chatService.saveLastMessage(widget.thread['id'], {
          'text': last['decrypted_text'] ?? '',
          'sent_at': last['sent_at'],
          'message_type': last['message_type'] ?? 'text',
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String> _decryptMessage(
    String threadKey,
    Map<String, dynamic> message,
  ) async {
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
          ChatService.zeroKeyB64,
          ciphertext,
          iv,
        );
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
      '_kind': 'text',
      'sender_key': 'user:local',
      'decrypted_text': text,
      'sent_at': DateTime.now().toIso8601String(),
      '_status': 'sending',
    };
    setState(() => _locals.add(local));
    _scrollToBottom();

    await _doSend(local);
  }

  Future<void> _retrySend(Map<String, dynamic> local) async {
    setState(() => local['_status'] = 'sending');
    await _doSend(local);
  }

  Future<void> _doSend(Map<String, dynamic> local) async {
    final text = (local['decrypted_text'] as String? ?? '').trim();
    if (text.isEmpty) return;

    try {
      final sent = await _chatService.sendMessage(
        widget.thread['id'],
        text,
        thread: _thread ?? widget.thread,
        messageType: local['_kind'] == 'discount' ? 'discount' : 'text',
        messageImageUrl: (local['message_image_url'] ?? '').toString(),
        productId: (local['product_id'] ?? '').toString(),
        oldPrice: (local['old_price'] ?? '').toString(),
        newPrice: (local['new_price'] ?? '').toString(),
        discountLink: (local['discount_link'] ?? '').toString(),
      );
      if (!mounted) return;
      setState(() {
        final serverId = sent?['id'];
        if (serverId is String && serverId.isNotEmpty) {
          local['id'] = serverId;
        }
        local.remove('_status');
      });
      _fetchMessages();
    } catch (e) {
      if (!mounted) return;
      setState(() => local['_status'] = 'failed');
      _scrollToBottom();
    }
  }

  Future<void> _openDiscountComposer() async {
    final nameCtrl = TextEditingController();
    final imageCtrl = TextEditingController();
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();

    final result = await showDialog<(String, String, String, String)>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send Discount Offer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Item name'),
              ),
              TextField(
                controller: imageCtrl,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              TextField(
                controller: oldCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Original price (SLE)',
                ),
              ),
              TextField(
                controller: newCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Discount price (SLE)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final oldP = oldCtrl.text.trim();
              final newP = newCtrl.text.trim();
              if (name.isEmpty || oldP.isEmpty || newP.isEmpty) return;
              Navigator.pop(ctx, (name, imageCtrl.text.trim(), oldP, newP));
            },
            child: const Text('Send Offer'),
          ),
        ],
      ),
    );

    nameCtrl.dispose();
    imageCtrl.dispose();
    oldCtrl.dispose();
    newCtrl.dispose();

    if (result == null || !mounted) return;
    final (name, imageUrl, oldPrice, newPrice) = result;

    final local = <String, dynamic>{
      'id': 'local-${DateTime.now().microsecondsSinceEpoch}',
      '_local': true,
      '_kind': 'discount',
      'sender_key': 'user:local',
      'decrypted_text': '$name at a discount price of $newPrice',
      'sent_at': DateTime.now().toIso8601String(),
      '_status': 'sending',
      'message_image_url': imageUrl,
      'product_id': '',
      'old_price': oldPrice,
      'new_price': newPrice,
      'discount_link': 'disc-${DateTime.now().microsecondsSinceEpoch}',
    };
    setState(() => _locals.add(local));
    _scrollToBottom();

    await _doSend(local);
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
              child: GestureDetector(
                onTap: () {
                  final shopId = widget.thread['shop_id'];
                  if (shopId is String && shopId.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MarketShopScreen(shopId: shopId),
                      ),
                    );
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.thread['shop_name'] ?? 'Official Store',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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
                      final Map<String, dynamic> message;
                      if (index < _messages.length) {
                        message = _messages[index];
                      } else {
                        message = _locals[index - _messages.length];
                      }
                      if (message['message_type'] == 'discount' ||
                          message['_kind'] == 'discount') {
                        return _buildDiscountBubble(message);
                      }
                      return _buildMessageBubble(message);
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
    final createdAt =
        message['sent_at'] as String? ?? DateTime.now().toIso8601String();
    String timeStr = '';
    try {
      timeStr = DateFormat.jm().format(DateTime.parse(createdAt));
    } catch (_) {}

    final bubbleColor = isMe
        ? (isDark ? const Color(0xFF333333) : const Color(0xFF1A1A1A))
        : (isDark ? theme.cardColor : const Color(0xFFEBECEF));
    final textColor = isMe
        ? (isDark ? const Color(0xFFE0E0E0) : Colors.white)
        : theme.colorScheme.onSurface;
    final timeColor = (isDark || !isMe)
        ? theme.colorScheme.onSurfaceVariant
        : Colors.white70;

    return GestureDetector(
      onLongPress: () => _showMessageActions(message),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bubbleColor,
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
                style: TextStyle(fontSize: 15, color: textColor),
              ),
              const SizedBox(height: 4),
              if (status == 'failed') ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 16,
                      color: Colors.redAccent,
                    ),
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
                    style: TextStyle(fontSize: 10, color: timeColor),
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
                    Icon(
                      Icons.done_all,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color shadowColor(ThemeData theme, bool isDark) {
    return isDark
        ? theme.shadowColor.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.08);
  }

  Color _accentButtonColor(ThemeData theme) {
    return theme.brightness == Brightness.dark
        ? theme.colorScheme.primary
        : _premiumBlack;
  }

  Future<void> _showMessageActions(Map<String, dynamic> message) async {
    final isLocal = message['_local'] == true;
    final senderKey = message['sender_key'] as String? ?? '';
    final isMe = isLocal || senderKey.startsWith('user:');
    if (!isMe) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Only messages you sent can be deleted'),
          ),
        );
      return;
    }

    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 8),
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Delete for everyone',
                style: TextStyle(color: Colors.red),
              ),
              subtitle: const Text(
                'Removes this message for both sides',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () => Navigator.pop(ctx, 'delete'),
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
    if (action != 'delete' || !mounted) return;

    final messageId = (message['id'] ?? '').toString();
    if (isLocal || messageId.startsWith('local-')) {
      setState(() {
        _locals.removeWhere((m) => (m['id'] ?? '') == messageId);
      });
      _scrollToBottom();
      return;
    }

    try {
      await _chatService.deleteMessage(widget.thread['id'], messageId);
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((m) => (m['id'] ?? '').toString() == messageId);
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Message deleted')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Could not delete message')),
        );
    }
  }

  Widget _buildDiscountBubble(Map<String, dynamic> message) {
    final theme = Theme.of(context);
    final isLocal = message['_local'] == true;
    final senderKey = message['sender_key'] as String? ?? '';
    final isMe = isLocal || senderKey.startsWith('user:');
    final status = message['_status'] as String? ?? '';
    final createdAt =
        message['sent_at'] as String? ?? DateTime.now().toIso8601String();
    final expired = _isDiscountExpired(createdAt);
    final oldNum = double.tryParse(message['old_price']?.toString() ?? '');
    final newNum = double.tryParse(message['new_price']?.toString() ?? '');
    final hasPrice = oldNum != null && newNum != null && newNum >= 0;
    final percent = (hasPrice && oldNum > 0)
        ? ((1 - (newNum / oldNum)) * 100).round().clamp(0, 100)
        : null;
    final imageUrl = (message['message_image_url'] ?? '').toString();
    final name = _discountItemName(message['decrypted_text'] ?? '');
    String timeStr = '';
    try {
      timeStr = DateFormat.jm().format(DateTime.parse(createdAt));
    } catch (_) {}

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.78).clamp(240.0, 320.0).toDouble();

    return GestureDetector(
      onLongPress: () => _showMessageActions(message),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: cardWidth,
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 0),
              bottomRight: Radius.circular(isMe ? 0 : 16),
            ),
            border: Border.all(color: theme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: shadowColor(theme, theme.brightness == Brightness.dark),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl.isNotEmpty)
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _discountImageFallback(theme),
                      )
                    else
                      _discountImageFallback(theme),
                    if ((percent != null || (newNum != null && newNum > 0)) &&
                        !expired)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFDC2626,
                            ).withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.percent,
                                size: 13,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                percent != null ? '$percent% OFF' : 'SALE',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (expired)
                      Container(
                        color: const Color(0xFF020617).withValues(alpha: 0.55),
                        alignment: Alignment.center,
                        child: const Text(
                          'Offer Expired',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (hasPrice) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          if (oldNum != newNum) ...[
                            Text(
                              'SLE ${oldNum.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.onSurfaceVariant,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            'SLE ${newNum.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (!expired) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFDC2626,
                          ).withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 13,
                              color: Color(0xFFDC2626),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Offer ends in ${_discountCountdown(createdAt)}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (status == 'failed') ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 16,
                            color: Colors.redAccent,
                          ),
                          TextButton(
                            onPressed: isLocal
                                ? () => _retrySend(message)
                                : null,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ] else if (!isMe)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: expired
                              ? null
                              : () {
                                  MarketCart().addItem(
                                    MarketCartItem(
                                      productId:
                                          (message['product_id'] ?? '')
                                              .toString()
                                              .isNotEmpty
                                          ? (message['product_id'] ?? '')
                                                .toString()
                                          : 'discount-${DateTime.now().millisecondsSinceEpoch}',
                                      name: name.isNotEmpty
                                          ? name
                                          : 'Discount Offer',
                                      price: newNum ?? oldNum ?? 0.0,
                                      imageUrl: imageUrl,
                                      shopId: (widget.thread['shop_id'] ?? '')
                                          .toString(),
                                      shopName:
                                          (widget.thread['shop_name'] ?? '')
                                              .toString(),
                                    ),
                                  );
                                  if (mounted) CartBottomSheet.show(context);
                                },
                          icon: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 16,
                          ),
                          label: Text(
                            expired ? 'Offer Expired' : 'Order This Item',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: _accentButtonColor(theme),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Offer sent to buyer',
                              style: TextStyle(fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
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
                          Icon(
                            Icons.done_all,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _discountImageFallback(ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      alignment: Alignment.center,
      child: Icon(
        Icons.shopping_bag_outlined,
        size: 34,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  bool _isDiscountExpired(String sentAtIso) {
    final sent = DateTime.tryParse(sentAtIso);
    if (sent == null) return false;
    return DateTime.now().isAfter(sent.add(const Duration(hours: 24)));
  }

  String _discountCountdown(String sentAtIso) {
    final sent = DateTime.tryParse(sentAtIso);
    if (sent == null) return '';
    final expiry = sent.add(const Duration(hours: 24));
    final remaining = expiry.difference(DateTime.now());
    if (remaining.isNegative) return '';
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  String _discountItemName(String text) {
    final match = RegExp(
      r'\s+at a discount price of\s+.*$',
      caseSensitive: false,
    ).firstMatch(text);
    if (match != null) return text.substring(0, match.start).trim();
    return text.trim();
  }

  Widget _buildMessageInput() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
      color: theme.cardColor,
      child: Row(
        children: [
          if (_isOrg)
            IconButton(
              onPressed: _openDiscountComposer,
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
            backgroundColor: _accentButtonColor(theme),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: theme.brightness == Brightness.dark
                    ? theme.colorScheme.onPrimary
                    : Colors.white,
                size: 20,
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
