import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class ChatService {
  // Generate a unique chat room ID for a user pair
  String getChatRoomId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return ids.join('_');
  }

  Future<String?> createChatRoom(String userId1, String userId2) async {
    final chatRoomId = getChatRoomId(userId1, userId2);
    final response = await http.post(
      Uri.parse('${ApiConstants.chats}/$chatRoomId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userIds': [userId1, userId2]}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['ID'] ?? data['id'];
    }
    return null;
  }

  Future<bool> sendMessage(String roomId, String senderId, String content) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.messages}/$roomId/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'senderId': senderId, 'content': content}),
    );
    return response.statusCode == 200;
  }

  Future<List<dynamic>> getMessages(String roomId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.messages}/$roomId/messages'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }
}
