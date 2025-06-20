class PetUpdateModel {
  final String id;
  final String time;
  final String caption;
  final String description;
  final String imageUrl;

  PetUpdateModel({
    required this.id,
    required this.time,
    required this.caption,
    required this.description,
    required this.imageUrl,
  });

  factory PetUpdateModel.fromJson(Map<String, dynamic> json) {
    return PetUpdateModel(
      id: json['id'] ?? '',
      time: json['time'] ?? '-',
      caption: json['caption'] ?? '-',
      description: json['description'] ?? '-',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
