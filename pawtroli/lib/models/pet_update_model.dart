
class PetUpdateModel {
  final String id;
  final String caption;
  final String description;
  final String imageUrl;
  final DateTime timestamp;

  PetUpdateModel({
    required this.id,
    required this.timestamp,
    required this.caption,
    required this.description,
    required this.imageUrl,
  });

  factory PetUpdateModel.fromJson(Map<String, dynamic> json) {
    // Parse timestamp from string to DateTime
    DateTime parsedTimestamp;
    try {
      final timestampValue = json['timestamp'] ?? json['Timestamp'];
      if (timestampValue is String) {
        parsedTimestamp = DateTime.parse(timestampValue);
      } else if (timestampValue is Map && timestampValue.containsKey('seconds')) {
        // Handle Firestore timestamp format
        final seconds = timestampValue['seconds'];
        parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      } else {
        parsedTimestamp = DateTime.now(); // Fallback
      }
    } catch (e) {
      print('Error parsing timestamp: $e');
      parsedTimestamp = DateTime.now(); // Fallback on error
    }

    return PetUpdateModel(
      id: json['id'] ?? json['ID'] ?? '',
      timestamp: parsedTimestamp,
      caption: json['caption'] ?? json['Caption'] ?? '-',
      description: json['description'] ?? json['Description'] ?? '-',
      imageUrl: json['imageUrl'] ?? json['ImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'caption': caption,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
