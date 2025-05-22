import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  static const Color headerGreen = Color(0xFF98D178); // Match notifications page
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
      //bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 30, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF98D178), // Match notifications page
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back button aligned to the left
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 30, color: Colors.black),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          // Centered settings icon and text
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.settings, size: 40, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                "Settings",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
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
        thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
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
}
