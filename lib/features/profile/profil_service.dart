import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // MENGAMBIL PROFIL MAHASISWA
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final document = await _firestore.collection('users').doc(user.uid).get();

    if (!document.exists) {
      return {
        'name': '',
        'nim': '',
        'prodi': '',
        'phone': '',
        'email': user.email ?? '',
      };
    }

    return document.data();
  }

  // MEMPERBARUI PROFIL MAHASISWA
  Future<void> updateCurrentUserProfile({
    required String name,
    required String nim,
    required String prodi,
    required String phone,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    await _firestore.collection('users').doc(user.uid).set({
      'name': name.trim(),
      'nim': nim.trim(),
      'prodi': prodi.trim(),
      'phone': phone.trim(),
    }, SetOptions(merge: true));
  }
}
