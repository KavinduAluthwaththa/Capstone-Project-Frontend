import 'package:flutter/material.dart';
import 'settings.dart'; // ✅ Import the SettingsPage

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardItem(
              icon: Icons.home_outlined,
              label: "Home",
              context: context,
              routeName: "/Home.dart",
            ),
            _buildDashboardItem(
              icon: Icons.chat_bubble_outline,
              label: "Chatbot",
              context: context,
              routeName: "/chatbot",
            ),
            _buildDashboardItem(
              icon: Icons.person_outline,
              label: "Profile",
              context: context,
              routeName: "/profile",
            ),
            _buildDashboardItem(
              icon: Icons.settings_outlined,
              label: "Settings",
              context: context,
              routeName: "/settings",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem({
    required IconData icon,
    required String label,
    required BuildContext context,
    required String routeName,
  }) {
    return GestureDetector(
      onTap: () {
        // ✅ Special case for Settings
        if (label == "Settings") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage()),
          );
        } else {
          Navigator.pushNamed(context, routeName);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: const Color(0xFF4A6B3E)),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}