import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/auth_service.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // AuthGate akan otomatis membuka HomeShell.
    } on FirebaseAuthException catch (e) {
      String message = 'Login gagal. Periksa kembali data kamu.';

      if (e.code == 'user-not-found') {
        message = 'Email belum terdaftar.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Email atau password salah.';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  const Icon(
                    Icons.directions_car,
                    size: 75,
                    color: Color(0xFF0A4EA2),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'CAMPUS CARPOOL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A4EA2),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Berbagi perjalanan, hemat biaya bersama.',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 35),

                  const Text(
                    'Masuk ke Akun',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,

                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),

                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email wajib diisi';
                      }

                      if (!value.contains('@')) {
                        return 'Format email tidak valid';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,

                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),

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
                      if (value == null || value.isEmpty) {
                        return 'Password wajib diisi';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    height: 50,

                    child: FilledButton(
                      onPressed: _loading ? null : _login,

                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'MASUK',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      const Text('Belum punya akun?'),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },

                        child: const Text('Daftar Sekarang'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
