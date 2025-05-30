import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart'; // Import your ChatService

class ChatPage extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String otherUserName;
  final String adminId; 
  const ChatPage({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.otherUserName,
    required this.adminId, // Admin ID for potential future use
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService(); // Initialize ChatService
  List<ChatMessage> _messages = []; // Store messages locally

  @override
  void initState() {
    super.initState();
    _loadMessages(); // Load messages when the chat page is opened
  }

  Future<void> _sendMessage(String content) async {
    await _chatService.sendMessage(widget.chatId, widget.currentUserId, content);
    _controller.clear(); 
    _loadMessages(); // Reload messages after sending
  }

  Future<void> _loadMessages() async {
    final messagesJson = await _chatService.getMessages(widget.chatId);
    setState(() {
      _messages = messagesJson.map<ChatMessage>((msg) {
        print('Message: $msg'); // Debugging line
        return ChatMessage(
          id: msg['id'] ?? '',
          senderId: msg['senderId'] ?? '',
          receiverId: msg['receiverId'] ?? '',
          text: msg['content'] ?? '',
           timestamp: msg['timestamp'] is String
              ? DateTime.parse(msg['timestamp'])
              : msg['timestamp'] is Map && msg['timestamp']['_seconds'] != null
                  ? DateTime.fromMillisecondsSinceEpoch(msg['timestamp']['_seconds'] * 1000)
                  : DateTime.now(),
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        leading: BackButton(),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg.senderId == widget.currentUserId;
                final msgDate = msg.timestamp.toUtc().add(const Duration(hours: 7));
                DateTime? prevDate;
                if (index > 0) {
                  prevDate = _messages[index - 1].timestamp.toUtc().add(const Duration(hours: 7));
                }

                final showDateSeparator = index == 0 || !_isSameDay(msgDate, prevDate!);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showDateSeparator)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(185, 0, 0, 0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _formatDateSeparator(msg.timestamp),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                    Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Color.fromRGBO(16, 48, 95, 1) : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.text,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _formatTimestamp(msg.timestamp),
                              style: TextStyle(
                                color: isMe ? Colors.white70 : Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue[700]),
                  onPressed: () => _sendMessage(_controller.text.trim()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final localTime = dateTime.toUtc().add(const Duration(hours: 7));
    final hour = localTime.hour > 12 ? localTime.hour - 12 : localTime.hour;
    final ampm = localTime.hour >= 12 ? 'pm' : 'am';
    return "${hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')} $ampm";
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isYesterday(DateTime a, DateTime b) {
    final aDate = DateTime(a.year, a.month, a.day);
    final bDate = DateTime(b.year, b.month, b.day);
    return aDate.difference(bDate).inDays == 1;
  }

  String _formatDateSeparator(DateTime dateTime) {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final localDate = dateTime.toUtc().add(const Duration(hours: 7));
    final difference = now.difference(localDate).inDays;

    if (_isSameDay(now, localDate)) {
      return "Today";
    } else if (_isYesterday(now, localDate)) {
      return "Yesterday";
    } else if (difference < 7) {
      // Show weekday name
      return [
        "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
      ][localDate.weekday - 1];
    } else {
      // Show formatted date
      return "${localDate.month}/${localDate.day}/${localDate.year}";
    }
  }
}
