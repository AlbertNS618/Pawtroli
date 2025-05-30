// lib/services/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'http://192.168.0.164:8080';
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/secure-endpoint';
  static const String pets = '$baseUrl/pets';
  static const String feeds = '$baseUrl/feeds';
  static const String chats = '$baseUrl/chats';
  static const String messages = '$baseUrl/chats'; // Use as $messages/{roomId}/messages
}