import 'package:flutter/material.dart';
import 'profile.dart';
import 'screens/user_settings.dart';
import 'screens/game_list.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  // final List<Widget> _screens = [
  //   const ProfilePage(),
  //   const UserSettingsScreen(),
  //   const AddGameScreen(),
  //   const GameListScreen(),
  // ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late final List<Widget> _screens = [
    const GameListScreen(),
    const ProfilePage(),
    const UserSettingsScreen(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF214D45),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Players',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Setting',
          ),
        ],
      ),
    );
  }
}
