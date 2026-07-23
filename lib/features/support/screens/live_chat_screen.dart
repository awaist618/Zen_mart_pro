import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../core/providers.dart';
import '../../../models/user_model.dart';
import '../../../models/order_model.dart';
import '../../../models/support_chat_model.dart';
import '../../../models/support_ticket_model.dart';
import '../../../services/support_service.dart';

class LiveChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  const LiveChatScreen({super.key, required this.chatId});

  @override
  ConsumerState<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends ConsumerState<LiveChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();
  bool _showEmojiPicker = false;
  bool _isRecording = false;
  String? _recordingPath;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _sendMessage({String type = 'text', String? attachmentUrl, String? linkedId, String? message}) async {
    final text = message ?? _messageController.text.trim();
    if (text.isEmpty && attachmentUrl == null) return;

    final user = ref.read(userModelProvider).asData?.value;
    if (user == null) return;

    final msg = SupportMessageModel(
      id: '',
      senderId: user.uid,
      senderName: user.name,
      senderRole: user.role.name,
      message: text,
      type: type,
      attachmentUrl: attachmentUrl,
      linkedId: linkedId,
      timestamp: DateTime.now(),
    );

    _messageController.clear();
    setState(() => _showEmojiPicker = false);
    
    await ref.read(supportServiceProvider).sendSupportMessage(widget.chatId, msg);
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      final url = await ref.read(uploadServiceProvider).uploadImage(File(pickedFile.path), folder: 'support_attachments');
      if (url != null) _sendMessage(type: 'image', attachmentUrl: url);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      final file = File(result.files.single.path!);
      final url = await ref.read(uploadServiceProvider).uploadImage(file, folder: 'support_docs'); // Reuse image upload for now
      if (url != null) _sendMessage(type: 'pdf', attachmentUrl: url, message: result.files.single.name);
    }
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      _recordingPath = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(const RecordConfig(), path: _recordingPath!);
      setState(() => _isRecording = true);
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    setState(() => _isRecording = false);
    if (path != null) {
      final url = await ref.read(uploadServiceProvider).uploadImage(File(path), folder: 'support_voice');
      if (url != null) _sendMessage(type: 'voice', attachmentUrl: url);
    }
  }

  void _attachOrder() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OrderPickerSheet(
        onOrderSelected: (order) {
          _sendMessage(type: 'order', linkedId: order.id, message: 'Attached Order #${order.id.substring(0, 8).toUpperCase()}');
          ref.read(supportServiceProvider).linkOrderToChat(widget.chatId, order.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userModelProvider).asData?.value;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final bgColor = isLight ? AppColors.lightBackground : AppColors.supportDarkBackground;
    final cardColor = isLight ? AppColors.lightSurface : AppColors.supportDarkSurface;
    final primaryColor = isLight ? AppColors.lightPrimary : AppColors.supportDarkPrimary;
    final textColor = isLight ? AppColors.lightTextPrimary : AppColors.supportDarkTextPrimary;
    final secondaryTextColor = isLight ? AppColors.lightTextSecondary : AppColors.supportDarkTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildHeader(primaryColor, textColor, secondaryTextColor, cardColor),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<SupportMessageModel>>(
              stream: ref.watch(supportServiceProvider).getSupportMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data ?? [];
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == user.uid;
                    return _ChatBubble(message: message, isMe: isMe, primary: primaryColor, cardColor: cardColor, textColor: textColor, secondaryTextColor: secondaryTextColor, isLight: isLight);
                  },
                );
              },
            ),
          ),
          if (_isRecording) _buildRecordingIndicator(primaryColor, textColor),
          _buildQuickReplies(primaryColor, cardColor),
          _buildInputArea(isLight, cardColor, textColor, secondaryTextColor, primaryColor),
          if (_showEmojiPicker) 
            SizedBox(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  _messageController.text += emoji.emoji;
                },
                config: const Config(
                  emojiViewConfig: EmojiViewConfig(
                    columns: 7,
                    verticalSpacing: 0,
                    horizontalSpacing: 0,
                    gridPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildHeader(Color primary, Color textColor, Color secondaryTextColor, Color cardColor) {
    return AppBar(
      backgroundColor: cardColor,
      elevation: 0.5,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textColor),
        onPressed: () => context.pop(),
      ),
      title: StreamBuilder<SupportChatModel?>(
        stream: ref.watch(supportServiceProvider).getChatStream(widget.chatId),
        builder: (context, snapshot) {
          final chat = snapshot.data;
          return Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: primary.withOpacity(0.1),
                child: Icon(Icons.support_agent_rounded, color: primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Zen MArt Support', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: textColor)),
                    Row(
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text('Online • Replies in 2m', style: TextStyle(fontSize: 10, color: secondaryTextColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildQuickReplies(Color primary, Color cardColor) {
    final replies = ['Order Issue', 'Refund', 'Payment', 'Delivery', 'Cancel Order'];
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: replies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) => ActionChip(
          label: Text(replies[index]),
          labelStyle: TextStyle(color: primary, fontSize: 11, fontWeight: FontWeight.w800),
          backgroundColor: primary.withOpacity(0.05),
          side: BorderSide(color: primary.withOpacity(0.1)),
          onPressed: () {
            _messageController.text = replies[index];
            _sendMessage();
          },
        ),
      ),
    );
  }

  Widget _buildRecordingIndicator(Color primary, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: primary.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.mic, color: Colors.red),
          const SizedBox(width: 12),
          Text('Recording...', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton(onPressed: () => setState(() => _isRecording = false), child: const Text('Cancel', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isLight, Color cardColor, Color textColor, Color secondaryTextColor, Color primary) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_showEmojiPicker ? Icons.keyboard_rounded : Icons.emoji_emotions_outlined, color: secondaryTextColor),
            onPressed: () => setState(() => _showEmojiPicker = !_showEmojiPicker),
          ),
          IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, color: secondaryTextColor),
            onPressed: _showAttachmentMenu,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isLight ? AppColors.lightSecondaryBackground : AppColors.supportDarkSecondaryBackground,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
                onChanged: (v) => ref.read(supportServiceProvider).setTypingStatus(widget.chatId, true, v.isNotEmpty),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.4), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onLongPress: _startRecording,
            onLongPressUp: _stopRecording,
            child: CircleAvatar(
              backgroundColor: primary,
              child: IconButton(
                icon: Icon(_messageController.text.isEmpty ? Icons.mic_rounded : Icons.send_rounded, color: Colors.white, size: 18),
                onPressed: _messageController.text.isEmpty ? null : () => _sendMessage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AttachmentBtn(icon: Icons.image_rounded, label: 'Image', color: Colors.blue, onTap: () { Navigator.pop(context); _pickImage(); }),
                _AttachmentBtn(icon: Icons.description_rounded, label: 'PDF', color: Colors.red, onTap: () { Navigator.pop(context); _pickFile(); }),
                _AttachmentBtn(icon: Icons.shopping_bag_rounded, label: 'Order', color: Colors.orange, onTap: () { Navigator.pop(context); _attachOrder(); }),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _AttachmentBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AttachmentBtn({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Column(
      children: [
        CircleAvatar(radius: 28, backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    ),
  );
}

class _ChatBubble extends StatelessWidget {
  final SupportMessageModel message;
  final bool isMe;
  final Color primary;
  final Color cardColor;
  final Color textColor;
  final Color secondaryTextColor;
  final bool isLight;

  const _ChatBubble({required this.message, required this.isMe, required this.primary, required this.cardColor, required this.textColor, required this.secondaryTextColor, required this.isLight});

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? primary : (isLight ? AppColors.lightSecondaryBackground : AppColors.supportDarkElevatedSurface);
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
            ),
            child: _buildMessageContent(context),
          ),
          const SizedBox(height: 4),
          Text(DateFormat('hh:mm a').format(message.timestamp), style: TextStyle(fontSize: 9, color: secondaryTextColor.withOpacity(0.5))),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case 'image':
        return ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(message.attachmentUrl!));
      case 'voice':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_arrow_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Container(width: 100, height: 2, color: Colors.white24),
          ],
        );
      case 'order':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 16), const SizedBox(width: 8), const Text('Linked Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))]),
            const SizedBox(height: 8),
            Text(message.message, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        );
      default:
        return Text(message.message, style: TextStyle(color: isMe ? Colors.white : textColor, fontSize: 14));
    }
  }
}

class _OrderPickerSheet extends ConsumerWidget {
  final Function(OrderModel) onOrderSelected;
  const _OrderPickerSheet({required this.onOrderSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(customerOrdersProvider);
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Order to Attach', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: ordersAsync.when(
              data: (orders) => ListView.separated(
                itemCount: orders.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return ListTile(
                    title: Text(order.shopName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Order #${order.id.substring(0, 8).toUpperCase()} • Rs ${order.totalAmount.round()}'),
                    onTap: () { Navigator.pop(context); onOrderSelected(order); },
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Error: $e'),
            ),
          ),
        ],
      ),
    );
  }
}
