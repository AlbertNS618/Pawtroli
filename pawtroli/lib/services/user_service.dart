import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final _usersCollection = FirebaseFirestore.instance.collection('users');

  Future<UserModel?> getUserById(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _usersCollection.doc(userId).update(data);
  }
}
