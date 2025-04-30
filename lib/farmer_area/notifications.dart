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
      debugShowCheckedModeBanner: false,
      home:  Notifications(),
    );
  }
}

// Model for Notification
class NotificationItem {
  final String title;
  final String time;
  final String date;

  NotificationItem({
    required this.title,
    required this.time,
    required this.date,
  });
}

class Notifications extends StatelessWidget {
   Notifications({super.key});

  // Sample data
  final List<NotificationItem> notifications =  [
    NotificationItem(title: "notification 1", time: "05.04 pm", date: "26 Feb 2025"),
    NotificationItem(title: "notification 2", time: "06.08 pm", date: "26 Feb 2025"),
    NotificationItem(title: "Offer update", time: "11.00 am", date: "25 Feb 2025"),
    NotificationItem(title: "Account alert", time: "02.15 pm", date: "25 Feb 2025"),
    NotificationItem(title: "Maintenance notice", time: "04.30 pm", date: "25 Feb 2025"),
  ];

  // Group notifications by date
  Map<String, List<NotificationItem>> _groupByDate(List<NotificationItem> items) {
    final Map<String, List<NotificationItem>> grouped = {};
    for (var item in items) {
      grouped.putIfAbsent(item.date, () => []).add(item);
    }
    return grouped;
  }

  Widget _dateSection(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
          const SizedBox(width: 8),
          Text(
            date,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _notificationTile(NotificationItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(item.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        subtitle: Text(item.time, style: GoogleFonts.poppins(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _bottomNavItem(IconData icon, String label, {bool active = false}) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? Colors.white : Colors.black),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: active ? Colors.white : Colors.black,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedNotifications = _groupByDate(notifications);

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30),
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
                const Icon(Icons.notifications, size: 40),
                const SizedBox(height: 8),
                Text(
                  "Notification",
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
            ),
          ),

          const SizedBox(height: 10),

          // Dynamic Notifications
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: groupedNotifications.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _dateSection(entry.key),
                      ...entry.value.map(_notificationTile).toList(),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          color: Color(0xFF6D8C50),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomNavItem(Icons.home, "Home"),
            _bottomNavItem(Icons.chat, "Com.chat"),
            _bottomNavItem(Icons.smart_toy, "AI chat bot"),
            _bottomNavItem(Icons.person, "My account", active: true),
          ],
        ),
      ),
    );
  }
}
