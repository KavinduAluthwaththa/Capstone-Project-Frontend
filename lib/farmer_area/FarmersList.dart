import 'package:flutter/material.dart';

void main() {
  runApp(const FarmersList());
}

class FarmersList extends StatelessWidget {
  const FarmersList({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const FarmersListPage(),
    );
  }
}

class FarmersListPage extends StatefulWidget {
  const FarmersListPage({super.key});

  @override
  _FarmersListPageState createState() => _FarmersListPageState();
}

class _FarmersListPageState extends State<FarmersListPage> {
  String _selectedSort = "Crop type";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4D3), // Light green background
      appBar: AppBar(
        title: const Text(
          "Farmers List",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: const Color(0xFF91C16C), // Dark greenish header
        centerTitle: true,
        toolbarHeight: 100, // Adjust the height as needed
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Sort Section
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF91C16C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "sort by >",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRadioButton("Crop type"),
                    _buildRadioButton("Location"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Farmers List
            Expanded(
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF91C16C), // Green button color
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        title: Text(
                          "Farmer ${index + 1}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: const Color(0xFF4A6B3E),
      //   selectedItemColor: Colors.white,
      //   unselectedItemColor: Colors.white70,
      //   showUnselectedLabels: true,
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: "Home",
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.cloud),
      //       label: "Com.chat",
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.android),
      //       label: "AI chat bot",
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: "My account",
      //     ),
      //   ],
      // ),
    );
  }

  // Radio Button Widget
  Widget _buildRadioButton(String title) {
    return Row(
      children: [
        Radio(
          value: title,
          groupValue: _selectedSort,
          activeColor: const Color(0xFF4A6B3E),
          onChanged: (value) {
            setState(() {
              _selectedSort = value.toString();
            });
          },
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
