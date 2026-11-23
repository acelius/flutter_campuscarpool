import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _prodiController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _prodiController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password tidak sama.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _authService.register(
        name: _nameController.text,
        nim: _nimController.text,
        prodi: _prodiController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      // AuthGate akan mendeteksi login otomatis setelah registrasi.
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      String message = 'Registrasi gagal.';

      if (e.code == 'email-already-in-use') {
        message = 'Email sudah digunakan.';
      } else if (e.code == 'weak-password') {
        message = 'Password terlalu lemah.';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,

        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),

        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label wajib diisi';
          }

          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrasi Mahasiswa')),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: ListView(
            padding: const EdgeInsets.all(24),

            children: [
              const Text(
                'Buat Akun Campus Carpool',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text('Lengkapi data diri kamu untuk mendaftar.'),

              const SizedBox(height: 25),

              _buildField(label: 'Nama Lengkap', controller: _nameController),

              _buildField(
                label: 'NIM',
                controller: _nimController,
                keyboardType: TextInputType.number,
              ),

              _buildField(label: 'Program Studi', controller: _prodiController),

              _buildField(
                label: 'Nomor WhatsApp',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),

              _buildField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,

                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),

                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              _buildField(
                label: 'Konfirmasi Password',
                controller: _confirmPasswordController,
                obscureText: true,
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 50,

                child: FilledButton(
                  onPressed: _loading ? null : _register,

                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'DAFTAR SEKARANG',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
