
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RideService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _rides =>
      _firestore.collection('rides');

  // MEMBUAT PUBLIKASI PERJALANAN
  Future<String> createRide({
    required String origin,
    required String destination,
    required DateTime departureDate,
    required String departureTime,
    required int availableSeats,
    required int pricePerSeat,
    String description = '',
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Kamu harus login terlebih dahulu.');
    }

    if (origin.trim().isEmpty ||
        destination.trim().isEmpty) {
      throw Exception('Lokasi tidak boleh kosong.');
    }

    if (availableSeats < 1 || pricePerSeat < 0) {
      throw Exception('Jumlah kursi atau biaya tidak valid.');
    }

    // CEK APAKAH DRIVER MASIH MEMILIKI PERJALANAN AKTIF
    final activeRides = await _rides
        .where('driverId', isEqualTo: user.uid)
        .get();

    final hasActiveRide = activeRides.docs.any((doc) {
      final status = doc.data()['status'];

      return status == 'available' ||
          status == 'in_progress';
    });

    if (hasActiveRide) {
      throw Exception(
        'Kamu masih memiliki perjalanan aktif. '
        'Selesaikan atau batalkan perjalanan sebelumnya '
        'sebelum membuat publikasi baru.',
      );
    }

    // AMBIL PROFIL DRIVER
    final profile = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    final profileName =
        profile.data()?['name'] as String?;

    // SIMPAN PUBLIKASI KE FIRESTORE
    final document = await _rides.add({
      'driverId': user.uid,
      'driverName': profileName ?? 'Pengemudi',
      'origin': origin.trim(),
      'destination': destination.trim(),
      'departureDate': Timestamp.fromDate(departureDate),
      'departureTime': departureTime,
      'availableSeats': availableSeats,
      'pricePerSeat': pricePerSeat,
      'description': description.trim(),
      'status': 'available',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  // MENAMPILKAN TUMPANGAN TERSEDIA
  Stream<List<Map<String, dynamic>>> watchAvailableRides() {
    return _rides
        .where('status', isEqualTo: 'available')
        .snapshots()
        .map((snapshot) {
      final rides = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      rides.sort((a, b) {
        final dateA = a['departureDate'] as Timestamp;
        final dateB = b['departureDate'] as Timestamp;

        return dateA.compareTo(dateB);
      });

      return rides;
    });
  }


  // MENAMPILKAN RIWAYAT PUBLIKASI DRIVER
  // URUTAN TERBARU KE TERLAMA
  Stream<List<Map<String, dynamic>>> watchMyRides() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _rides
        .where('driverId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      final rides = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      // URUTKAN BERDASARKAN WAKTU PUBLIKASI
      rides.sort((a, b) {
        final createdAtA = a['createdAt'];
        final createdAtB = b['createdAt'];

        final dateA = createdAtA is Timestamp
            ? createdAtA.toDate()
            : DateTime.fromMillisecondsSinceEpoch(0);

        final dateB = createdAtB is Timestamp
            ? createdAtB.toDate()
            : DateTime.fromMillisecondsSinceEpoch(0);

        // Terbaru ditampilkan paling atas
        return dateB.compareTo(dateA);
      });

      return rides;
    });
  }

  // MEMBATALKAN PUBLIKASI
  Future<void> cancelRide(String rideId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Kamu belum login.');
    }

    final document = await _rides.doc(rideId).get();

    if (!document.exists) {
      throw Exception('Perjalanan tidak ditemukan.');
    }

    if (document.data()?['driverId'] != user.uid) {
      throw Exception('Kamu tidak memiliki izin.');
    }

    await _rides.doc(rideId).update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // MENYELESAIKAN PERJALANAN
  Future<void> completeRide(String rideId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Kamu belum login.');
    }

    final document = await _rides.doc(rideId).get();

    if (!document.exists) {
      throw Exception('Perjalanan tidak ditemukan.');
    }

    final data = document.data()!;

    if (data['driverId'] != user.uid) {
      throw Exception('Kamu tidak memiliki izin.');
    }

    final status = data['status'];

    if (status != 'available' &&
        status != 'in_progress') {
      throw Exception(
        'Perjalanan tidak dapat diselesaikan.',
      );
    }

    await _rides.doc(rideId).update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
