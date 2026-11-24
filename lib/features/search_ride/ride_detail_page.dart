import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'booking_service.dart';

class RideDetailPage extends StatefulWidget {
  final Map<String, dynamic> ride;

  const RideDetailPage({
    super.key,
    required this.ride,
  });

  @override
  State<RideDetailPage> createState() => _RideDetailPageState();
}

class _RideDetailPageState extends State<RideDetailPage> {
  static const Color primaryBlue = Color(0xFF0A4EA2);

  bool _isSubmitting = false;

  DateTime? _getDepartureDate() {
    final value = widget.ride['departureDate'];

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';

    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatPrice(dynamic value) {
    final price = value is num ? value.toInt() : 0;

    return 'Rp ${price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    )}';
  }

  Widget _buildInfo(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: primaryBlue,
            size: 23,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitBooking() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await BookingService().createBooking(
        ride: widget.ride,
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
            title: const Text('Pengajuan Berhasil'),
            content: const Text(
              'Permintaan booking kamu sudah dikirim.\n\n'
              'Status Booking: PENDING\n\n'
              'Silakan tunggu konfirmasi dari Driver.',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Mengerti'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst(
        'Exception: ',
        '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;

    final currentUser = FirebaseAuth.instance.currentUser;

    final isOwnRide =
        ride['driverId'] == currentUser?.uid;

    final seats =
        (ride['availableSeats'] as num?)?.toInt() ?? 0;

    final isAvailable =
        ride['status'] == 'available' && seats > 0;

    final driverName =
        ride['driverName']?.toString() ?? 'Pengemudi';

    final origin = ride['origin']?.toString() ?? '-';

    final destination =
        ride['destination']?.toString() ?? '-';

    final departureTime =
        ride['departureTime']?.toString() ?? '-';

    final description =
        ride['description']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Tumpangan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.directions_car,
                    color: primaryBlue,
                    size: 45,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    '$origin → $destination',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Informasi Perjalanan',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfo(
                      Icons.location_on,
                      'Lokasi Asal',
                      origin,
                    ),

                    const Divider(),

                    _buildInfo(
                      Icons.flag,
                      'Lokasi Tujuan',
                      destination,
                    ),

                    const Divider(),

                    _buildInfo(
                      Icons.calendar_month,
                      'Tanggal Keberangkatan',
                      _formatDate(_getDepartureDate()),
                    ),

                    const Divider(),

                    _buildInfo(
                      Icons.access_time,
                      'Jam Keberangkatan',
                      departureTime,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Informasi Driver',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEAF3FF),
                  child: Icon(
                    Icons.person,
                    color: primaryBlue,
                  ),
                ),
                title: Text(
                  driverName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text('Pengemudi'),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Informasi Tambahan',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfo(
                      Icons.event_seat,
                      'Kursi Tersedia',
                      '$seats kursi',
                    ),

                    const Divider(),

                    _buildInfo(
                      Icons.payments,
                      'Harga Per Kursi',
                      _formatPrice(ride['pricePerSeat']),
                    ),

                    if (description.isNotEmpty) ...[
                      const Divider(),

                      _buildInfo(
                        Icons.description,
                        'Deskripsi',
                        description,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (isOwnRide)
              const Text(
                'Ini adalah perjalanan yang kamu publikasikan sendiri.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: isAvailable && !_isSubmitting
                      ? _submitBooking
                      : null,

                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),

                  label: Text(
                    _isSubmitting
                        ? 'Mengirim Pengajuan...'
                        : isAvailable
                            ? 'Ajukan Booking'
                            : 'Tumpangan Tidak Tersedia',
                  ),

                  style: FilledButton.styleFrom(
                    backgroundColor: primaryBlue,
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            if (!isOwnRide)
              const Text(
                'Booking akan berstatus menunggu sampai Driver memberikan konfirmasi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}