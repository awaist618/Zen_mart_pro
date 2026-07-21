import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpCustomer({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('users').doc(credential.user!.uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'role': 'customer',
      'shopId': null,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _db
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      rethrow;
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
