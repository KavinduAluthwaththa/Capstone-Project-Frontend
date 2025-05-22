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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom Header
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 40, bottom: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF6ABC4D),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 20),
                const Text(
                  "Farmers List",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          // ...rest of your body (sort button, list, etc.)...
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Sort Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFABD298),
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
                    ],
                  ),
                  // Farmers List
                  Expanded(
                    child: ListView.builder(
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFABD298),
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
          ),
        ],
      ),
    );
  }
}
