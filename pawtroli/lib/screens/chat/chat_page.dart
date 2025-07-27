import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pawtroli/design_constant.dart';
import '../../models/chat_message.dart';
import '../../services/chat_service.dart';

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
    required this.adminId, 
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService(); 
  final ScrollController _scrollController = ScrollController(); 
  List<ChatMessage> _messages = []; 
  Timer? _pollingTimer;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); 
    _loadMessages();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _loadMessages();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose(); 
    super.dispose();
  }

  Future<void> _sendMessage(String content) async {
    await _chatService.sendMessage(widget.chatId, widget.currentUserId, content);
    _controller.clear();
    await _loadMessages(); 
    _scrollToBottom();
  }

  Future<void> _loadMessages() async {
    final messagesJson = await _chatService.getMessages(widget.chatId);
    final newMessages = messagesJson.map<ChatMessage>((msg) {
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

    final shouldScroll = newMessages.length > _lastMessageCount || _isNearBottom();

    setState(() {
      _messages = newMessages;
      _lastMessageCount = newMessages.length;
    });

    if (shouldScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients) return true;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return (maxScroll - currentScroll) < 100;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void didChangeMetrics() {
    // Called when the window metrics change (e.g., keyboard pops up)
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    if (bottomInset > 0) {
      // Keyboard is visible
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
    super.didChangeMetrics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: DesignConstant.pawBlue,
        title: Text(widget.otherUserName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        toolbarHeight: 80,
        leading: BackButton(color: Colors.white,),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
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
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe ? DesignConstant.pawBlue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatTimestamp(msg.timestamp),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: DesignConstant.pawBlue),
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
