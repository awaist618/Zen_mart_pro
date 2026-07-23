import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../core/providers.dart';
import '../../models/support_chat_model.dart';
import '../../models/support_ticket_model.dart';
import '../../services/support_service.dart';

class SupportChatDetailScreen extends ConsumerStatefulWidget {
  final String userId;
  final String userName;
  const SupportChatDetailScreen({super.key, required this.userId, required this.userName});

  @override
  ConsumerState<SupportChatDetailScreen> createState() => _SupportChatDetailScreenState();
}

class _SupportChatDetailScreenState extends ConsumerState<SupportChatDetailScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _chatId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() async {
    final chatId = await ref.read(supportServiceProvider).getOrCreateChat(widget.userId, widget.userName, null);
    if (mounted) {
      setState(() => _chatId = chatId);
      ref.read(supportServiceProvider).markChatAsRead(chatId);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _chatId == null) return;

    final user = ref.read(userModelProvider).asData?.value;
    if (user == null) return;

    final text = _messageController.text.trim();
    _messageController.clear();

    final msg = SupportMessageModel(
      id: '',
      senderId: user.uid,
      senderName: user.name,
      senderRole: 'super_admin',
      message: text,
      timestamp: DateTime.now(),
    );

    await ref.read(supportServiceProvider).sendSupportMessage(_chatId!, msg);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleEndChat() {
    if (_chatId == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.dialog,
        title: const Text('Resolve Chat?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('This will mark the conversation as completed.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              ref.read(supportServiceProvider).endChat(_chatId!);
              Navigator.pop(context);
              context.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('MARK RESOLVED'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_chatId == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            const Text('LIVE CHAT SUPPORT', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
            tooltip: 'Resolve Chat',
            onPressed: _handleEndChat,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<SupportMessageModel>>(
              stream: ref.watch(supportServiceProvider).getSupportMessages(_chatId!),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                
                final messages = snapshot.data ?? [];

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderRole == 'super_admin' || message.senderRole == 'admin';

                    return _ChatBubble(message: message, isMe: isMe);
                  },
                );
              },
            ),
          ),
          
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      onChanged: (v) => ref.read(supportServiceProvider).setTypingStatus(_chatId!, false, v.isNotEmpty),
                      decoration: const InputDecoration(
                        hintText: 'Type your reply...',
                        hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: AppColors.background, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final SupportMessageModel message;
  final bool isMe;

  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : AppColors.elevatedSurface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 20),
              ),
            ),
            child: Text(
              message.message,
              style: TextStyle(color: isMe ? AppColors.background : Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Text(
              DateFormat('hh:mm a').format(message.timestamp),
              style: const TextStyle(color: AppColors.textHint, fontSize: 10),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
