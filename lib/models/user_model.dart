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
  
  // Rider & Vendor specific
  final bool isOnline;
  final String? vehicleInfo;
  final String? licenseNumber;
  final double rating;
  final int totalDeliveries;
  final double totalEarnings;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.shopId,
    required this.status,
    required this.createdAt,
    this.isOnline = false,
    this.vehicleInfo,
    this.licenseNumber,
    this.rating = 0.0,
    this.totalDeliveries = 0,
    this.totalEarnings = 0.0,
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
      isOnline: data['isOnline'] ?? false,
      vehicleInfo: data['vehicleInfo'],
      licenseNumber: data['licenseNumber'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalDeliveries: data['totalDeliveries'] ?? 0,
      totalEarnings: (data['totalEarnings'] ?? 0.0).toDouble(),
    );
  }

  static UserRole _parseRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'super_admin':
      case 'admin':
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
      'isOnline': isOnline,
      'vehicleInfo': vehicleInfo,
      'licenseNumber': licenseNumber,
      'rating': rating,
      'totalDeliveries': totalDeliveries,
      'totalEarnings': totalEarnings,
    };
  }
}
