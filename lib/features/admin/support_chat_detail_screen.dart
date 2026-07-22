import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../core/providers.dart';

class SupportChatDetailScreen extends ConsumerStatefulWidget {
  final String userId;
  final String userName;
  const SupportChatDetailScreen({super.key, required this.userId, required this.userName});

  @override
  ConsumerState<SupportChatDetailScreen> createState() => _SupportChatDetailScreenState();
}

class _SupportChatDetailScreenState extends ConsumerState<SupportChatDetailScreen> {
  final _messageController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _markAsRead() async {
    final chatId = 'support_${widget.userId}';
    await _db.collection('support_chats').doc(chatId).update({'unreadCount': 0});
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final user = ref.read(userModelProvider).asData?.value;
    if (user == null) return;

    final text = _messageController.text.trim();
    _messageController.clear();

    final chatId = 'support_${widget.userId}';

    await _db.collection('support_chats').doc(chatId).set({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _db.collection('support_chats').doc(chatId).collection('messages').add({
      'text': text,
      'senderId': user.uid,
      'senderName': user.name,
      'timestamp': FieldValue.serverTimestamp(),
      'isFromAdmin': true,
    });

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

  @override
  Widget build(BuildContext context) {
    final chatId = 'support_${widget.userId}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text('User Support Request', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('support_chats').doc(chatId).collection('messages')
                  .orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final docs = snapshot.data?.docs ?? [];

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isMe = data['isFromAdmin'] ?? false;
                    final timestamp = data['timestamp'] as Timestamp?;
                    final timeStr = timestamp != null ? DateFormat('hh:mm a').format(timestamp.toDate()) : '';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isMe ? AppColors.primary : Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(20),
                                      topRight: const Radius.circular(20),
                                      bottomLeft: Radius.circular(isMe ? 20 : 0),
                                      bottomRight: Radius.circular(isMe ? 0 : 20),
                                    ),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                                  ),
                                  child: Text(
                                    data['text'] ?? '',
                                    style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                            child: Text(
                              timeStr,
                              style: TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your reply...',
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
