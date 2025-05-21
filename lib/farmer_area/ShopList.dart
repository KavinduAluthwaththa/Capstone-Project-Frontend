import 'package:flutter/material.dart';

class Shoplist extends StatefulWidget {
  const Shoplist({super.key});

  @override
  State<Shoplist> createState() => _ShoplistState();
}

class _ShoplistState extends State<Shoplist> {
  @override
  Widget build(BuildContext context) {
    return const ShopListPage();
  }
}

class ShopListPage extends StatefulWidget {
  const ShopListPage({super.key});

  @override
  _ShopListPageState createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage> {
  String _selectedSort = "Crop type";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Full page background set to white
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Back navigation
          },
        ),
        title: const Text(
          "Shop List",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.green[400], // Green header
        centerTitle: true,
        toolbarHeight: 100, // Custom height
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
                    backgroundColor: Colors.green[400],
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

            // Shop List
            Expanded(
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        title: Text(
                          "Shop ${index + 1}",
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

      // Optional Bottom Navigation Bar
      // Uncomment if needed
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

  // Helper to build radio buttons
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
