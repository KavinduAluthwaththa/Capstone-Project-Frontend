import 'package:flutter/material.dart';

import 'Home.dart';
import 'Dashboard.dart';

void main() => runApp(const BottomNavigationBarExampleApp());

class BottomNavigationBarExampleApp extends StatelessWidget {
  const BottomNavigationBarExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: BottomNavigationBarExample());
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() => _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    Text('Chatbot'),
    Text('Chat'),
    DashboardPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
            backgroundColor: Color(0xFF4A6B3E),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_outlined),
            label: 'Chat',
            backgroundColor: Color(0xFF4A6B3E),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chatbot',
            backgroundColor: Color(0xFF4A6B3E),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_customize_outlined),
            label: 'MyAccount',
            backgroundColor: Color(0xFF4A6B3E),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}