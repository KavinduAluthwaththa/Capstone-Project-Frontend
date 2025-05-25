import 'package:capsfront/farmer_area/MyOrders.dart';
import 'package:capsfront/shared/settings.dart';
import 'package:flutter/material.dart';
import 'package:capsfront/shared/notifications.dart';
import 'package:capsfront/shared/Chatbot.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final int _selectedIndex = 2; // Profile tab

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/shopOwnerHome');
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChatbotPage()),
      );
    }
    // No action for index 2 (Profile), already here
  }

  Widget _buildProfileContent() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green[400],
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Colors.black),
              ),
              const SizedBox(height: 10),
              const Text(
                "Name",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              Text(
                "user@gmail.com",
                style: TextStyle(color: Colors.black.withOpacity(0.6)),
              ),
              Text(
                "Location",
                style: TextStyle(color: Colors.black.withOpacity(0.6)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ProfileOption(
          icon: Icons.notifications,
          title: "Notifications",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Notifications()),
            );
          },
        ),
        ProfileOption(
          icon: Icons.receipt_long,
          title: "My orders",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyOrdersPage()),
            );
          },
        ),
        ProfileOption(
          icon: Icons.settings,
          title: "Settings",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _buildProfileContent()),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green.shade800.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(title, style: const TextStyle(color: Colors.black87, fontSize: 18)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black38, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }
}
