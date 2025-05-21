import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Settings Page Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto', // Or any preferred font
      ),
      home: const SettingsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  int _selectedIndex = 3; // Default to "My account"

  // Define colors from the image
  static const Color headerGreen = Color(0xFFA5D6A7); // A light, slightly desaturated green
  static const Color itemGreen = Color(0xFFE8F5E9); // Very light green for items
  static const Color bottomNavGreen = Color(0xFF558B2F); // Darker green for bottom nav
  static const Color iconColor = Colors.black87;
  static const Color textColor = Colors.black87;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation to other pages if needed
    // e.g., if (index == 0) Navigator.pushNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                children: [
                  _buildUserProfile(),
                  const SizedBox(height: 30),
                  _buildNotificationSetting(),
                  const SizedBox(height: 15),
                  _buildLanguageSetting(),
                  const SizedBox(height: 30), // More space before Log out
                  _buildLogoutButton(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 15, // Status bar height + padding
        bottom: 50, // Increased padding for the curve effect
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: headerGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  // Handle back navigation
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ),
          const Text(
            'Settings',
            style: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return InkWell(
      onTap: () {
        // Navigate to profile edit page
        print("User profile tapped");
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFFD3CFCF), // Greyish color for avatar
              child: Text(
                'U',
                style: TextStyle(fontSize: 24, color: Colors.black54, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "User's name",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "user@gmail.com",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: itemGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSetting() {
    return _buildSettingItem(
      title: 'Notifications',
      trailing: Switch(
        value: _notificationsEnabled,
        onChanged: (bool value) {
          setState(() {
            _notificationsEnabled = value;
          });
        },
        activeColor: Colors.white, // Color of the thumb when active
        activeTrackColor: Colors.black, // Color of the track when active
        inactiveThumbColor: Colors.grey[300],
        inactiveTrackColor: Colors.grey[400],
        thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              // Icon for active state (thumb)
              return const Icon(Icons.check, color: Colors.black);
            }
            return null; // No icon for inactive state
          },
        ),
      ),
    );
  }

  Widget _buildLanguageSetting() {
    return _buildSettingItem(
      title: 'Language',
      trailing: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'EN',
            style: TextStyle(
              fontSize: 16,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
        ],
      ),
      onTap: () {
        // Navigate to language selection page
        print("Language setting tapped");
      },
    );
  }

  Widget _buildLogoutButton() {
    return _buildSettingItem(
      title: 'Log out',
      trailing: const Icon(Icons.logout, color: iconColor, size: 28),
      onTap: () {
        // Handle log out
        print("Log out tapped");
        // Example: show confirmation dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Log Out'),
              content: const Text('Are you sure you want to log out?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Log Out', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Perform actual logout logic here
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // Ensures all items are visible
      backgroundColor: bottomNavGreen,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(0.7),
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled), // Using filled icon as in image
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.cloud_outlined), // Using outlined as in image
          label: 'Com.chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.smart_toy_outlined), // A robot/AI icon
          label: 'AI chat bot',
        ),
        BottomNavigationBarItem(
          icon: SizedBox.shrink(), // No icon for "My account" as per image
          label: 'My account',
        ),
      ],
    );
  }
}
