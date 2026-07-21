import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
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

  /// Super Admin creating Vendor/Rider without logging out
  Future<void> createSubUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role, // 'vendor' or 'rider'
    String? shopName,
    String? shopCategory,
  }) async {
    // 1. Initialize a secondary Firebase app instance
    // This allows creating a user without affecting the current admin session
    FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'secondaryAuthApp',
      options: Firebase.app().options,
    );

    try {
      FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      
      // 2. Create the user in Firebase Auth
      UserCredential credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      String uid = credential.user!.uid;
      String? shopId;

      // 3. If it's a vendor, create a shop document first
      if (role == 'vendor' && shopName != null) {
        DocumentReference shopRef = _db.collection('shops').doc();
        shopId = shopRef.id;
        await shopRef.set({
          'name': shopName,
          'vendorId': uid,
          'category': shopCategory ?? 'General',
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 4. Create the User Profile in Firestore
      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'shopId': shopId,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // 5. Sign out from secondary instance
      await secondaryAuth.signOut();
    } finally {
      // 6. Delete the secondary app instance to clean up
      await secondaryApp.delete();
    }
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
