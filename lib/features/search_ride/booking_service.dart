import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // MEMBUAT PENGAJUAN BOOKING
  Future<String> createBooking({
    required Map<String, dynamic> ride,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }

    final rideId = ride['id']?.toString() ?? '';

    if (rideId.isEmpty) {
      throw Exception('ID perjalanan tidak ditemukan.');
    }

    final rideRef = _firestore.collection('rides').doc(rideId);

    // Satu dokumen booking untuk satu penumpang dan perjalanan.
    final bookingRef = _firestore
        .collection('bookings')
        .doc('${rideId}_${user.uid}');

    // Tidak boleh memesan perjalanan sendiri.
    if (ride['driverId'] == user.uid) {
      throw Exception(
        'Kamu tidak dapat memesan perjalanan sendiri.',
      );
    }

    // Mengambil nama penumpang.
    final profile = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    final passengerName =
        profile.data()?['name']?.toString().trim();

    final name = (passengerName == null || passengerName.isEmpty)
        ? (user.displayName ?? 'Mahasiswa')
        : passengerName;

    return await _firestore.runTransaction((transaction) async {
      final rideSnapshot = await transaction.get(rideRef);
      final bookingSnapshot = await transaction.get(bookingRef);

      if (!rideSnapshot.exists) {
        throw Exception('Perjalanan tidak ditemukan.');
      }

      final rideData = rideSnapshot.data()!;

      if (rideData['driverId'] == user.uid) {
        throw Exception(
          'Kamu tidak dapat memesan perjalanan sendiri.',
        );
      }

      if (rideData['status'] != 'available') {
        throw Exception(
          'Perjalanan ini sudah tidak tersedia.',
        );
      }

      final availableSeats =
          (rideData['availableSeats'] as num?)?.toInt() ?? 0;

      if (availableSeats < 1) {
        throw Exception('Kursi sudah habis.');
      }

      // Mencegah pengajuan booking berulang.
      if (bookingSnapshot.exists) {
        final existingStatus =
            bookingSnapshot.data()?['status'];

        if ([
          'pending',
          'accepted',
          'approved',
          'confirmed',
        ].contains(existingStatus)) {
          throw Exception(
            'Kamu sudah memiliki pengajuan pada perjalanan ini.',
          );
        }
      }

      transaction.set(bookingRef, {
        'rideId': rideId,
        'driverId': rideData['driverId'],
        'passengerId': user.uid,
        'passengerName': name,
        'origin': rideData['origin'],
        'destination': rideData['destination'],
        'departureDate': rideData['departureDate'],
        'departureTime': rideData['departureTime'],
        'pricePerSeat': rideData['pricePerSeat'],
        'seatsRequested': 1,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return bookingRef.id;
    });
  }
}