import 'package:first_flutter_project/network/chat_service.dart';
import 'package:first_flutter_project/pages/chat/chat_thread_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => ChatListScreenState();
}

class ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> _threads = [];
  bool _isLoading = true;
  bool _searchActive = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadThreads();
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

  Future<void> _loadThreads() async {
    try {
      final threads = await _chatService.getThreads();
      if (mounted) {
        setState(() {
          _threads = threads;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
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
        setState(() => _threads.removeWhere((t) => t['id'] == thread['id']));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete thread: $e')),
        );
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
            .where((t) =>
                (t['shop_name'] ?? '').toString().toLowerCase().contains(query))
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
                        separatorBuilder: (context, index) =>
                            Divider(height: 1, indent: 80, color: theme.dividerColor),
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
    final lastMessageAt = DateTime.tryParse(thread['updated_at'] ?? '') ?? DateTime.now();
    final timeStr = DateFormat.jm().format(lastMessageAt);
    final isUnread = thread['unread_count'] != null && thread['unread_count'] > 0;

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatThreadScreen(thread: thread)),
        ).then((_) => _loadThreads());
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        foregroundImage:
            (thread['shop_image'] != null && (thread['shop_image'] as String).isNotEmpty)
                ? NetworkImage(thread['shop_image'] as String)
                : null,
        onForegroundImageError: thread['shop_image'] != null ? (_, _) {} : null,
        backgroundColor: Colors.grey.shade200,
        child: const Icon(Icons.store),
      ),
      title: Text(
        thread['shop_name'] ?? 'Official Store',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          thread['last_message'] ?? 'Tap to start chatting',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isUnread ? Colors.black87 : Colors.grey.shade600,
            fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: 12,
                  color: isUnread ? Colors.green : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 4),
              if (isUnread)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  child: Text(
                    '${thread['unread_count']}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                size: 20, color: theme.colorScheme.onSurfaceVariant),
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
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
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