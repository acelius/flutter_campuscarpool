import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // REGISTRASI
  Future<void> register({
    required String name,
    required String nim,
    required String prodi,
    required String phone,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Registrasi gagal.');
    }

    await _firestore.collection('users').doc(user.uid).set({
      'name': name.trim(),
      'nim': nim.trim(),
      'prodi': prodi.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'vehicle': '',
      'rating': 0.0,
      'ratingCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // LOGIN
  Future<void> login({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
