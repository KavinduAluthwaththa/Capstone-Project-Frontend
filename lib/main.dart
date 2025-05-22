import 'package:flutter/material.dart';
import 'package:capsfront/shop_owner_area/shop_owner_main_page.dart';
import 'package:capsfront/farmer_area/farmer_main_page.dart';
import 'package:capsfront/shared/Chat.dart';
import 'package:capsfront/shared/Chatbot.dart';
import 'package:capsfront/shared/profile_page.dart';
import 'package:capsfront/shared/Splash.dart';
import 'package:capsfront/shared/settings.dart';

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
      home: const SettingsPage(), // Set Splashscreen as the initial page
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

  final List<Widget> _pages = [
    //ShopOwnerMainPage(email: 'shopowner@mail.com'),
    FarmerMainPage(email: 'farmer@mail.com'),
    ChatbotPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.green[400],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'Ask me'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

