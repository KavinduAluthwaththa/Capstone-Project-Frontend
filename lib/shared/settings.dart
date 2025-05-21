import 'package:flutter/material.dart';

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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back
          },
        ),
        title: Text("Settings"),
        backgroundColor: Colors.green[400],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.green[400],
            child: Row(
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
                Spacer(),
                Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
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
