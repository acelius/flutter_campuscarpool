import 'package:flutter/material.dart';

import '../features/home/home_page.dart';
import '../features/search_ride/search_ride_page.dart';
import '../features/offer_ride/offer_ride_page.dart';
import '../features/offer_ride/my_rides_page.dart';
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
    'Cari Tumpangan',
    'Tawarkan Tumpangan',
    'Perjalanan Saya',
    'Profil',
  ];

  late final List<Widget> _pages = [
    HomePage(),
    const SearchRidePage(),
    const OfferRidePage(),
    MyRidesPage(),
    const ProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

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
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Cari',
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