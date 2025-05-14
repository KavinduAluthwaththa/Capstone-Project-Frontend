import 'package:flutter/material.dart';
import 'package:capsfront/shared/Splash.dart';
import 'package:capsfront/shop_owner_area/shop_owner_main_page.dart';
import 'package:capsfront/shared/Chat.dart';
import 'package:capsfront/shared/Chatbot.dart';
import 'package:capsfront/shared/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const Splashscreen(), // Set Splashscreen as the initial screen
    );
  }
}

class BottomNavigationHandler extends StatefulWidget {
  const BottomNavigationHandler({super.key});

  @override
  State<BottomNavigationHandler> createState() => _BottomNavigationHandlerState();
}

class _BottomNavigationHandlerState extends State<BottomNavigationHandler> {
  int _selectedIndex = 0;

  // List of pages for each tab
  final List<Widget> _pages = [
    ShopOwnerMainPage(email: 'example@example.com'), // Home page
    ChatPage(), // Chat page
    ChatbotPage(), // AI Chatbot page
    ProfilePage(), // My Account page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex, // Show the selected page
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.green.shade800,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Com.chat'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'AI chat bot'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My account'),
        ],
      ),
    );
  }
}