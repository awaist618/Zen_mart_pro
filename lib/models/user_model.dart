import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  superAdmin,
  vendor,
  customer,
  rider,
  unknown
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? shopId;
  final String status;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.shopId,
    required this.status,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: _parseRole(data['role']),
      shopId: data['shopId'],
      status: data['status'] ?? 'active',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  static UserRole _parseRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'super_admin':
      case 'admin': // Alias for convenience
        return UserRole.superAdmin;
      case 'vendor':
        return UserRole.vendor;
      case 'customer':
        return UserRole.customer;
      case 'rider':
        return UserRole.rider;
      default:
        return UserRole.unknown;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name.replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), '_').toLowerCase(),
      'shopId': shopId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
