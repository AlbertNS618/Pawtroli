class PetModel {
  final String petId;
  final String name;
  final String type;
  final String age;
  final String ownerId;
  final String imageUrl;

  PetModel({
    required this.petId,
    required this.name,
    required this.type,
    required this.age,
    required this.ownerId,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    "petId": petId,
    "name": name,
    "type": type,
    "age": age,
    "ownerId": ownerId,
    "imageUrl": imageUrl,
  };

  factory PetModel.fromJson(Map<String, dynamic> json) => PetModel(
    petId: json["petId"] ?? "",
    name: json["name"] ?? "",
    type: json["type"] ?? "",
    age: json["age"] ?? "",
    ownerId: json["ownerId"] ?? "",
    imageUrl: json["imageUrl"] ?? "",
  );
}