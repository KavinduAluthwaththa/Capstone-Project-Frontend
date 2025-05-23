import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const FarmersListPage(), // Directly use FarmersListPage
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "Farmers List",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.green[400], // Match ShopListPage
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
            // Sort Section (optional, uncomment if needed)
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   children: [
            //     ElevatedButton(
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: Colors.green[400],
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(12),
            //         ),
            //       ),
            //       onPressed: () {},
            //       child: const Text(
            //         "sort by >",
            //         style: TextStyle(
            //           fontWeight: FontWeight.bold,
            //           fontSize: 16,
            //           color: Colors.black,
            //         ),
            //       ),
            //     ),
            //     const SizedBox(width: 16),
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         _buildRadioButton("Crop type"),
            //         _buildRadioButton("Location"),
            //       ],
            //     ),
            //   ],
            // ),
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
                        color: Colors.green[300],
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
    );
  }

  // Helper to build radio buttons (if you want to use sort section)
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
