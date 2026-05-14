import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatRoomView extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;
  ChatRoomView({super.key});

  Color _background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final chatId = args['chatId'];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F1115) : const Color(0xFFF5F7FB);
    final myMsgColor = isDark
        ? const Color(0xFF2563EB)
        : const Color(0xFF3B82F6);
    final otherMsgColor = isDark
        ? const Color(0xFF1F2937)
        : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _background(context),
        title: Text(
          args['userName'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          ///  MESSAGE LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading messages"));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                if (messages.isEmpty) {
                  return const Center(child: Text("No messages yet"));
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;

                    final isMe = msg['senderId'] == currentUser!.uid;

                    return _messageBubble(
                      msg: msg,
                      isMe: isMe,
                      myColor: myMsgColor,
                      otherColor: otherMsgColor,
                      theme: theme,
                    );
                  },
                );
              },
            ),
          ),

          /// ✏️ INPUT BOX
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  /// TEXT FIELD
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1A1D23)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: messageController,
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  /// SEND BUTTON
                  GestureDetector(
                    onTap: () async {
                      if (messageController.text.trim().isEmpty) return;

                      final text = messageController.text.trim();

                      await _firestore
                          .collection('chats')
                          .doc(chatId)
                          .collection('messages')
                          .add({
                            "senderId": currentUser!.uid,
                            "message": text,
                            "timestamp": FieldValue.serverTimestamp(),
                          });

                      await _firestore.collection('chats').doc(chatId).update({
                        "lastMessage": text,
                        "lastMessageTime": FieldValue.serverTimestamp(),
                      });

                      messageController.clear();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 💬 MESSAGE BUBBLE
  Widget _messageBubble({
    required Map<String, dynamic> msg,
    required bool isMe,
    required Color myColor,
    required Color otherColor,
    required ThemeData theme,
  }) {
    final time = msg['timestamp'];

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: isMe ? myColor : otherColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isMe
                    ? const Radius.circular(16)
                    : const Radius.circular(4),
                bottomRight: isMe
                    ? const Radius.circular(4)
                    : const Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  msg['message'] ?? "",
                  style: TextStyle(
                    color: isMe
                        ? Colors.white
                        : theme.textTheme.bodyLarge?.color,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(time),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🕒 FORMAT TIME
  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return "";

    try {
      final date = (timestamp as Timestamp).toDate();
      return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "";
    }
  }
}
