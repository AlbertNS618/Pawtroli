import 'package:cloud_firestore/cloud_firestore.dart';

class PetModel {
  final String petId;
  final String name;
  final String type;
  final int age;
  final String ownerId;
  final String imageUrl;
  final String gender;
  final String color;
  final String allergy;
  final String other;
  final String? status;
  final bool? active;
  final Timestamp? checkIn;
  final Timestamp? checkOut;

  PetModel({
    required this.petId,
    required this.name,
    required this.type,
    required this.age,
    required this.ownerId,
    required this.imageUrl,
    required this.gender,
    required this.color,
    required this.allergy,
    required this.other,
    this.status,
    this.active,
    this.checkIn,
    this.checkOut,
  });

  Map<String, dynamic> toJson() => {
    "petId": petId,
    "name": name,
    "type": type,
    "age": age,
    "ownerId": ownerId,
    "imageUrl": imageUrl,
    "gender": gender,
    "color": color,
    "allergy": allergy,
    "other": other,
    "status": status,
    "active": false,
  };

factory PetModel.fromJson(Map<String, dynamic> json) {
  return PetModel(
    petId: json['id'] ?? '',
    name: json['name'] ?? '',
    type: json['type'] ?? '',
    gender: json['gender'] ?? '',
    age: json['age'] is int ? json['age'] : (json['age'] is double ? (json['age'] as double).toInt() : 0),
    color: json['color'] ?? '',
    allergy: json['allergy'] ?? '',
    other: json['other'] ?? '',
    ownerId: json['ownerId'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
    active: json['active'] ?? false,
    status: json['status'] ?? '-',
    checkIn: json['checkIn'] is Timestamp ? json['checkIn'] as Timestamp : null,
    checkOut: json['checkOut'] is Timestamp ? json['checkOut'] as Timestamp : null,
  );
}
}