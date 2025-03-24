import 'package:flutter/material.dart';

class Constants {
  static final Color primaryColor = Colors.green.shade400;
  static final Color secondaryColor = Colors.green.shade800;
  static final Color textColor = Colors.black87;
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Constants.primaryColor,
              borderRadius: const BorderRadius.only(
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
                Text(
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
          ProfileOption(icon: Icons.notifications, title: "Notifications"),
          ProfileOption(icon: Icons.receipt_long, title: "My orders"),
          ProfileOption(icon: Icons.settings, title: "Settings"),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Constants.secondaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: "Com.chat"),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: "AI chat bot"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "My account"),
        ],
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;

  const ProfileOption({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Constants.primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(title, style: TextStyle(color: Constants.textColor, fontSize: 18)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black38, size: 16),
        ),
      ),
    );
  }
}
