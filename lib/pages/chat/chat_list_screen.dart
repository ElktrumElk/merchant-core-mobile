import 'dart:async';

import 'package:first_flutter_project/network/chat_service.dart';
import 'package:first_flutter_project/pages/chat/chat_thread_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Total unread negotiation messages across all shops, surfaced as a badge on
/// the Negotiate tab in the bottom navigation bar.
final ValueNotifier<int> negotiationUnreadCount = ValueNotifier<int>(0);

/// Refreshes the badge count from the server. Used by a shell-level timer so
/// new messages are reflected even while the Negotiate tab isn't mounted (the
/// list screen is disposed when you switch tabs, so its own 10s poll only runs
/// while the tab is active).
Future<void> refreshNegotiationUnread() async {
  final service = ChatService();
  try {
    final threads = await service.getThreads();
    var total = 0;
    for (final thread in threads) {
      total += await service.unreadCountFor(thread);
    }
    negotiationUnreadCount.value = total;
  } catch (_) {}
}

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => ChatListScreenState();
}

class ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> _threads = [];
  Map<String, int> _unread = {};
  Map<String, Map<String, dynamic>> _lastMessages = {};
  bool _isLoading = true;
  bool _searchActive = false;
  String _query = '';
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadThreads();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }

  void startPolling() {
    _pollTimer ??= Timer.periodic(
      const Duration(seconds: 10),
      (_) => _loadThreads(silent: true),
    );
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void activateSearch() {
    setState(() {
      _searchActive = true;
      _query = '';
    });
  }

  void _closeSearch() {
    setState(() {
      _searchActive = false;
      _query = '';
    });
  }

  void _syncUnreadBadge() {
    negotiationUnreadCount.value = _unread.values.fold(
      0,
      (sum, count) => sum + count,
    );
  }

  Future<void> _loadThreads({bool silent = false}) async {
    if (!silent) {
      final cached = await _chatService.loadCachedThreads();
      if (cached != null && cached.isNotEmpty && mounted) {
        final hydrated = await _chatService.hydrateThreadsWithShopImages(
          cached,
        );
        if (mounted) {
          setState(() {
            _threads = hydrated;
            _isLoading = false;
          });
        }
        await _loadUnreadAndPreviews(hydrated);
      }
    }
    try {
      final threads = await _chatService.getThreads();
      if (mounted) {
        setState(() {
          _threads = threads;
          _isLoading = false;
        });
      }
      await _loadUnreadAndPreviews(threads);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUnreadAndPreviews(
    List<Map<String, dynamic>> threads,
  ) async {
    final unread = <String, int>{};
    final previews = await _chatService.loadLastMessages();
    for (final t in threads) {
      final id = t['id'];
      if (id == null) continue;
      unread[id] = await _chatService.unreadCountFor(t);
    }
    if (mounted) {
      setState(() {
        _unread = unread;
        _lastMessages = previews;
      });
      _syncUnreadBadge();
    }

    final missing = <Map<String, dynamic>>[];
    for (final t in threads) {
      final id = t['id'];
      final lastAt = t['last_message_at'];
      if (id == null || lastAt == null) continue;
      final existing = previews[id];
      if (existing == null || existing['sent_at'] != lastAt) {
        missing.add(t);
      }
    }
    if (missing.isEmpty) return;

    final fetched = Map<String, Map<String, dynamic>>.from(previews);
    for (var i = 0; i < missing.length; i += 3) {
      final batch = missing.skip(i).take(3).toList();
      final results = await Future.wait(
        batch.map((t) async {
          final preview = await _chatService.fetchLastMessagePreview(t);
          if (preview == null || t['id'] == null) return null;
          return MapEntry(t['id'], preview);
        }),
      );
      for (final e in results) {
        if (e != null) fetched[e.key] = e.value;
      }
    }
    await _chatService.saveLastMessages(fetched);
    if (mounted) setState(() => _lastMessages = fetched);
  }

  void _openThread(Map<String, dynamic> thread) {
    final id = thread['id'];
    _chatService.markThreadRead(id);
    setState(() {
      if (id != null) _unread[id] = 0;
    });
    _syncUnreadBadge();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatThreadScreen(thread: thread)),
    ).then((_) => _loadThreads());
  }

  Future<void> _confirmDelete(Map<String, dynamic> thread) async {
    final shopName = thread['shop_name'] ?? 'this shop';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: Text(
          'This will permanently delete the conversation with $shopName for everyone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _chatService.deleteThread(thread['id']);
      if (mounted) {
        setState(() {
          _threads.removeWhere((t) => t['id'] == thread['id']);
          _unread.remove(thread['id']);
          _lastMessages.remove(thread['id']);
        });
        _syncUnreadBadge();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete thread: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? _threads
        : _threads
              .where(
                (t) => (t['shop_name'] ?? '').toString().toLowerCase().contains(
                  query,
                ),
              )
              .toList();

    return Column(
      children: [
        if (_searchActive) _buildSearchField(theme),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadThreads,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      indent: 80,
                      color: theme.dividerColor,
                    ),
                    itemBuilder: (context, index) =>
                        _buildThreadTile(filtered[index]),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      color: theme.cardColor,
      child: TextField(
        autofocus: true,
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: 'Search conversations',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _closeSearch,
          ),
          isDense: true,
          filled: true,
          fillColor: theme.scaffoldBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildThreadTile(Map<String, dynamic> thread) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final preview = _lastMessages[thread['id']];
    final lastText = (preview?['text'] ?? '').toString().trim();
    final isDiscount = preview?['message_type'] == 'discount';
    final unread = _unread[thread['id']] ?? 0;
    final isUnread = unread > 0;

    final lastAtRaw = thread['last_message_at'] ?? thread['created_at'];
    final lastMessageAt = DateTime.tryParse(lastAtRaw ?? '');
    final timeStr = lastMessageAt != null
        ? DateFormat.jm().format(lastMessageAt)
        : '';

    final shopImage = (thread['shop_image'] ?? '').toString().trim();

    return ListTile(
      onTap: () => _openThread(thread),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        foregroundImage: shopImage.isNotEmpty ? NetworkImage(shopImage) : null,
        onForegroundImageError: shopImage.isNotEmpty ? (_, _) {} : null,
        backgroundColor: Colors.grey.shade200,
        child: const Icon(Icons.store),
      ),
      title: Text(
        thread['shop_name'] ?? 'Official Store',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: isUnread
              ? (isDark ? Colors.white : Colors.black)
              : theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: lastText.isEmpty
            ? Text(
                'Tap to start chatting',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isUnread
                      ? (isDark ? Colors.white : Colors.black87)
                      : Colors.grey.shade600,
                  fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                ),
              )
            : Row(
                children: [
                  if (isDiscount) ...[
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 15,
                      color: isUnread
                          ? (isDark ? Colors.white : Colors.black87)
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(
                      lastText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isUnread
                            ? (isDark ? Colors.white : Colors.black87)
                            : Colors.grey.shade600,
                        fontWeight: isUnread
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (timeStr.isNotEmpty)
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: isUnread ? Colors.green : Colors.grey.shade500,
                  ),
                ),
              if (timeStr.isNotEmpty) const SizedBox(height: 4),
              if (isUnread)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$unread',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: () => _confirmDelete(thread),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final message = _searchActive && _query.isNotEmpty
        ? 'No conversations match your search'
        : 'No messages yet';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchActive && _query.isNotEmpty
                ? 'Try a different search term'
                : 'Start a conversation with a shop!',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
