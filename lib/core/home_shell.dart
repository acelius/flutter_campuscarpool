import 'package:flutter/material.dart';

import '../features/profile/profil_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Beranda',
    'Tawarkan Tumpangan',
    'Perjalanan Saya',
    'Profil',
  ];

  late final List<Widget> _pages = [
    const PlaceholderPage(
      title: 'Beranda',
      icon: Icons.home_outlined,
      description: 'Selamat datang di Campus Carpool.',
    ),
    const PlaceholderPage(
      title: 'Tawarkan Tumpangan',
      icon: Icons.directions_car_outlined,
      description: 'Fitur menawarkan perjalanan akan dikembangkan.',
    ),
    const PlaceholderPage(
      title: 'Perjalanan Saya',
      icon: Icons.route_outlined,
      description: 'Daftar perjalanan kamu akan ditampilkan di sini.',
    ),
    const ProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: IndexedStack(index: _selectedIndex, children: _pages),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,

        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),

          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Tawarkan',
          ),

          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route),
            label: 'Perjalanan',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icon, size: 75, color: const Color(0xFF0A4EA2)),

            const SizedBox(height: 20),

            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(description, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
