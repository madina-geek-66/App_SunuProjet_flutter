import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? _uid;
  String? _fullName;
  String? _email;
  String? _role;
  bool? _isActive;
  DateTime? _createdAt;
  String? _photoURL;

  String? get uid => _uid;
  String? get fullName => _fullName;
  String? get email => _email;
  String? get role => _role;
  bool? get isActive => _isActive;
  DateTime? get createdAt => _createdAt;
  String? get photoUrl => _photoURL;

  UserModel({
    required String uid,
    required String fullName,
    required String email,
    required String role,
    required bool isActive,
    required DateTime createdAt,
    required String photoUrl,
  }){
    _uid = uid;
    _fullName = fullName;
    _email = email;
    _role = role;
    _isActive = isActive;
    _createdAt = createdAt;
    _photoURL = photoUrl;
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      photoUrl: data['photoURL'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt!),
      'photoURL': photoUrl ?? '',
    };
  }


}
