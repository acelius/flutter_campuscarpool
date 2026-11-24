import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../offer_ride/ride_service.dart';
import 'ride_detail_page.dart';

class SearchRidePage extends StatefulWidget {
  const SearchRidePage({super.key});

  @override
  State<SearchRidePage> createState() => _SearchRidePageState();
}

class _SearchRidePageState extends State<SearchRidePage> {
  static const Color primaryBlue = Color(0xFF0A4EA2);

  final RideService _rideService = RideService();

  final TextEditingController _originController =
      TextEditingController();

  final TextEditingController _destinationController =
      TextEditingController();

  DateTime? _selectedDate;

  String _appliedOrigin = '';
  String _appliedDestination = '';
  DateTime? _appliedDate;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  // MEMILIH TANGGAL KEBERANGKATAN
  Future<void> _selectDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      helpText: 'Pilih tanggal keberangkatan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // MENJALANKAN PENCARIAN
  void _searchRides() {
    setState(() {
      _appliedOrigin =
          _originController.text.trim().toLowerCase();

      _appliedDestination =
          _destinationController.text.trim().toLowerCase();

      _appliedDate = _selectedDate;
    });
  }

  // MENGATUR ULANG FILTER
  void _resetFilters() {
    setState(() {
      _originController.clear();
      _destinationController.clear();

      _selectedDate = null;

      _appliedOrigin = '';
      _appliedDestination = '';
      _appliedDate = null;
    });
  }

  // MENGUBAH TIMESTAMP MENJADI DATETIME
  DateTime? _getDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  // MEMBANDINGKAN TANGGAL
  bool _sameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  // FORMAT TANGGAL
  String _formatDate(DateTime date) {
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

  // FORMAT HARGA
  String _formatPrice(dynamic value) {
    final price = value is num ? value.toInt() : 0;

    final formatted = price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return 'Rp $formatted';
  }

  // MENGAMBIL JUMLAH KURSI
  int _getSeats(dynamic value) {
    return value is num ? value.toInt() : 0;
  }

  // FILTER DATA TUMPANGAN
  List<Map<String, dynamic>> _filterRides(
    List<Map<String, dynamic>> rides,
  ) {
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid;

    final today = DateTime.now();

    final todayOnly = DateTime(
      today.year,
      today.month,
      today.day,
    );

    final filtered = rides.where((ride) {
      final origin =
          (ride['origin'] ?? '').toString().toLowerCase();

      final destination =
          (ride['destination'] ?? '').toString().toLowerCase();

      final departureDate =
          _getDate(ride['departureDate']);

      if (departureDate == null) {
        return false;
      }

      final dateOnly = DateTime(
        departureDate.year,
        departureDate.month,
        departureDate.day,
      );

      // TIDAK MENAMPILKAN PERJALANAN YANG SUDAH LEWAT
      if (dateOnly.isBefore(todayOnly)) {
        return false;
      }

      // DRIVER TIDAK BISA MEMESAN PERJALANANNYA SENDIRI
      if (currentUserId != null &&
          ride['driverId'] == currentUserId) {
        return false;
      }

      // FILTER LOKASI ASAL
      if (_appliedOrigin.isNotEmpty &&
          !origin.contains(_appliedOrigin)) {
        return false;
      }

      // FILTER LOKASI TUJUAN
      if (_appliedDestination.isNotEmpty &&
          !destination.contains(_appliedDestination)) {
        return false;
      }

      // FILTER TANGGAL
      if (_appliedDate != null &&
          !_sameDate(departureDate, _appliedDate!)) {
        return false;
      }

      return true;
    }).toList();

    // URUTKAN DARI KEBERANGKATAN TERDEKAT
    filtered.sort((a, b) {
      final dateA = _getDate(a['departureDate'])!;
      final dateB = _getDate(b['departureDate'])!;

      final comparison = dateA.compareTo(dateB);

      if (comparison != 0) {
        return comparison;
      }

      return (a['departureTime'] ?? '')
          .toString()
          .compareTo(
            (b['departureTime'] ?? '').toString(),
          );
    });

    return filtered;
  }

  // FORM PENCARIAN
  Widget _buildSearchForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _originController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Lokasi Asal',
              hintText: 'Contoh: Solo',
              prefixIcon: Icon(
                Icons.my_location,
                color: primaryBlue,
              ),
            ),
          ),

          const SizedBox(height: 14),

          TextField(
            controller: _destinationController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Lokasi Tujuan',
              hintText: 'Contoh: Kampus',
              prefixIcon: Icon(
                Icons.location_on_outlined,
                color: primaryBlue,
              ),
            ),
          ),

          const SizedBox(height: 14),

          InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Tanggal Keberangkatan',
                prefixIcon: Icon(
                  Icons.calendar_month,
                  color: primaryBlue,
                ),
              ),
              child: Text(
                _selectedDate == null
                    ? 'Semua tanggal'
                    : _formatDate(_selectedDate!),
                style: TextStyle(
                  color: _selectedDate == null
                      ? Colors.grey.shade600
                      : Colors.black87,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _searchRides,
                    icon: const Icon(Icons.search),
                    label: const Text('Cari'),
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryBlue,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              OutlinedButton(
                onPressed: _resetFilters,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(90, 48),
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // KARTU TUMPANGAN YANG BISA DITEKAN
  Widget _buildRideCard(Map<String, dynamic> ride) {
    final departureDate =
        _getDate(ride['departureDate']);

    final driverName =
        (ride['driverName'] ?? 'Pengemudi').toString();

    final origin =
        (ride['origin'] ?? '-').toString();

    final destination =
        (ride['destination'] ?? '-').toString();

    final departureTime =
        (ride['departureTime'] ?? '-').toString();

    final seats =
        _getSeats(ride['availableSeats']);

    final price =
        _formatPrice(ride['pricePerSeat']);

    return InkWell(
      borderRadius: BorderRadius.circular(16),

      // MEMBUKA HALAMAN DETAIL
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RideDetailPage(
              ride: ride,
            ),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFEAF3FF),
                  child: Icon(
                    Icons.person,
                    color: primaryBlue,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    driverName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),

            const Divider(height: 24),

            Row(
              children: [
                const Icon(
                  Icons.circle,
                  size: 12,
                  color: Colors.green,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    origin,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Container(
                height: 22,
                width: 2,
                color: Colors.grey.shade300,
              ),
            ),

            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 17,
                  color: Colors.red,
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Text(
                    destination,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Wrap(
              spacing: 16,
              runSpacing: 10,
              children: [
                _infoItem(
                  Icons.calendar_today,
                  departureDate == null
                      ? '-'
                      : _formatDate(departureDate),
                ),

                _infoItem(
                  Icons.access_time,
                  departureTime,
                ),

                _infoItem(
                  Icons.event_seat,
                  '$seats kursi',
                ),
              ],
            ),

            const Divider(height: 24),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Harga per penumpang',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

                Text(
                  price,
                  style: const TextStyle(
                    color: primaryBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Lihat detail perjalanan →',
                style: TextStyle(
                  color: primaryBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // INFORMASI KECIL PADA KARTU
  Widget _infoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),

        const SizedBox(width: 5),

        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // TAMPILAN JIKA TIDAK ADA HASIL
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 52,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 12),

          const Text(
            'Tumpangan Tidak Ditemukan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Belum ada perjalanan yang sesuai dengan pencarianmu.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _rideService.watchAvailableRides(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Gagal mengambil data perjalanan:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final rides = snapshot.data ?? [];

          final filteredRides =
              _filterRides(rides);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(18),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Temukan Tumpangan',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Cari perjalanan bersama mahasiswa lainnya.',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 20),

                _buildSearchForm(),

                const SizedBox(height: 26),

                const Text(
                  'Perjalanan Tersedia',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                if (snapshot.connectionState ==
                        ConnectionState.waiting &&
                    !snapshot.hasData)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else ...[
                  Text(
                    '${filteredRides.length} perjalanan ditemukan',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (filteredRides.isEmpty)
                    _buildEmptyState()
                  else
                    ...filteredRides.map(_buildRideCard),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}