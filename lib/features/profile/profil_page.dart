import 'package:flutter/material.dart';

import '../../core/auth_service.dart';
import 'profil_service.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final ProfilService _profilService = ProfilService();
  final AuthService _authService = AuthService();

  late Future<Map<String, dynamic>?> _profilFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _profilFuture = _profilService.getCurrentUserProfile();
  }

  Future<void> _refreshProfile() async {
    final future = _profilService.getCurrentUserProfile();

    setState(() {
      _profilFuture = future;
    });

    await future;
  }

  // EDIT PROFIL
  Future<void> _editProfile(
    Map<String, dynamic> data,
  ) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return EditProfilDialog(data: data);
      },
    );

    if (!mounted || result == null) return;

    try {
      await _profilService.updateCurrentUserProfile(
        name: result['name']!,
        nim: result['nim']!,
        prodi: result['prodi']!,
        phone: result['phone']!,
      );

      if (!mounted) return;

      await _refreshProfile();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui.'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui profil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // LOGOUT
  Future<void> _logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal logout: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _profilFuture,

      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Gagal mengambil profil: ${snapshot.error}',
            ),
          );
        }

        final data = snapshot.data ?? {};

        final name = data['name']?.toString() ?? 'Mahasiswa';
        final nim = data['nim']?.toString() ?? '-';
        final prodi = data['prodi']?.toString() ?? '-';
        final phone = data['phone']?.toString() ?? '-';
        final email = data['email']?.toString() ?? '-';

        return ListView(
          padding: const EdgeInsets.all(20),

          children: [
            const SizedBox(height: 15),

            const CircleAvatar(
              radius: 45,
              backgroundColor: Color(0xFFE1ECFA),
              child: Icon(
                Icons.person,
                size: 55,
                color: Color(0xFF0A4EA2),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              name.isEmpty ? 'Mahasiswa' : name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              email,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Informasi Mahasiswa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Divider(height: 25),

                    _profileItem('Nama', name),
                    _profileItem('NIM', nim),
                    _profileItem('Program Studi', prodi),
                    _profileItem('WhatsApp', phone),
                    _profileItem('Email', email),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: () => _editProfile(data),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profil'),
            ),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Keluar dari Akun'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _profileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// DIALOG EDIT PROFIL
// Controller dimiliki oleh dialog sendiri,
// sehingga lifecycle-nya mengikuti widget dialog.

class EditProfilDialog extends StatefulWidget {
  final Map<String, dynamic> data;

  const EditProfilDialog({
    super.key,
    required this.data,
  });

  @override
  State<EditProfilDialog> createState() =>
      _EditProfilDialogState();
}

class _EditProfilDialogState
    extends State<EditProfilDialog> {

  late final TextEditingController _nameController;
  late final TextEditingController _nimController;
  late final TextEditingController _prodiController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.data['name']?.toString() ?? '',
    );

    _nimController = TextEditingController(
      text: widget.data['nim']?.toString() ?? '',
    );

    _prodiController = TextEditingController(
      text: widget.data['prodi']?.toString() ?? '',
    );

    _phoneController = TextEditingController(
      text: widget.data['phone']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _prodiController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profil'),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
              ),
            ),

            TextField(
              controller: _nimController,
              decoration: const InputDecoration(
                labelText: 'NIM',
              ),
            ),

            TextField(
              controller: _prodiController,
              decoration: const InputDecoration(
                labelText: 'Program Studi',
              ),
            ),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor WhatsApp',
              ),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Batal'),
        ),

        FilledButton(
          onPressed: () {
            Navigator.pop(
              context,
              {
                'name': _nameController.text.trim(),
                'nim': _nimController.text.trim(),
                'prodi': _prodiController.text.trim(),
                'phone': _phoneController.text.trim(),
              },
            );
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}