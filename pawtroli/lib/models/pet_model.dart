import 'dart:developer' as developer;

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
  final dynamic checkIn; 
  final dynamic checkOut;

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
    "status": status ?? '-',
    "active": false,
    "checkIn": checkOut,
    "checkOut": checkOut,
  };

  factory PetModel.fromJson(Map<String, dynamic> json) {
    // Add debug log to see the exact data structure
    developer.log('Parsing pet with raw data: $json');
    
    // Handle case-sensitive fields from Go backend
    return PetModel(
      petId: json['ID'] ?? json['id'] ?? json['PetID'] ?? json['petId'] ?? '',
      name: json['Name'] ?? json['name'] ?? '',
      type: json['Type'] ?? json['type'] ?? '',
      gender: json['Gender'] ?? json['gender'] ?? '',
      age: json['Age'] ?? json['age'] ?? 0,
      color: json['Color'] ?? json['color'] ?? '',
      allergy: json['Allergy'] ?? json['allergy'] ?? '',
      other: json['Other'] ?? json['other'] ?? '',
      ownerId: json['OwnerID'] ?? json['ownerId'] ?? '',
      imageUrl: json['ImageURL'] ?? json['imageUrl'] ?? '',
      active: json['Active'] ?? json['active'] ?? false,
      status: json['Status'] ?? json['status'] ?? '',
      checkIn: json['CheckIn'] ?? json['checkIn'],
      checkOut: json['CheckOut'] ?? json['checkOut'],
    );
  }

  PetModel copyWith({
    String? name,
    String? type,
    String? gender,
    String? color,
    int? age,
    String? allergy,
    String? other,
    String? status,
    String? imageUrl,
    bool? active,
    dynamic checkIn,
    dynamic checkOut,
  }) {
    return PetModel(
      petId: petId,
      name: name ?? this.name,
      type: type ?? this.type,
      age: age ?? this.age,
      ownerId: ownerId,
      imageUrl: imageUrl ?? this.imageUrl,
      gender: gender ?? this.gender,
      color: color ?? this.color,
      allergy: allergy ?? this.allergy,
      other: other ?? this.other,
      status: status ?? this.status,
      active: active ?? this.active,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
    );
  }
}