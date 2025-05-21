import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SettingsPage(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 30, bottom: 30),
            decoration: const BoxDecoration(
              color: Color(0xFF98D178),
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
                icon: const Icon(Icons.arrow_back, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Centered notification icon and text
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.settings, size: 40),
                const SizedBox(height: 8),
                Text(
                  "Settings",
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
            ),
          ),
          ListTile(
            title: Row(
              children: [
                CircleAvatar(
                  child: Text("U"),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("User’s name", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("user@gmail.com", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
          ListTile(
            title: Text("Location"),
            subtitle: Text("Colombo, Sri Lanka"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
          SwitchListTile(
            title: Text("Notifications"),
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
          ListTile(
            title: Text("Language"),
            subtitle: Text("EN"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
          ListTile(
            title: Text("Log out", style: TextStyle(color: Colors.red)),
            trailing: Icon(Icons.logout, color: Colors.red),
            onTap: () {},
          ),
        ],
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   type: BottomNavigationBarType.fixed,
      //   backgroundColor: Colors.green.shade800,
      //   selectedItemColor: Colors.white,
      //   unselectedItemColor: Colors.white70,
      //   items: [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      //     BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Com.chat"),
      //     BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: "AI chat bot"),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: "My account"),
      //   ],
      // ),
    );
  }
}
