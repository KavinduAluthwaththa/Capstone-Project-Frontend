import 'package:capsfront/shop_owner_area/FarmersList.dart';
import 'package:capsfront/shop_owner_area/OrderRequest.dart';
import 'package:capsfront/shared/Chatbot.dart';        // <-- Import ChatbotPage
import 'package:capsfront/shared/profile_page.dart';   // <-- Import ProfilePage
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
      home: const ShopOwnerMainPage(email: 'shopowner@mail.com'), // Provide a test email here
    );
  }
}

class ShopOwnerMainPage extends StatefulWidget {
  final String email;
  const ShopOwnerMainPage({super.key, required this.email});

  @override
  State<ShopOwnerMainPage> createState() => _ShopOwnerMainPageState();
}

class _ShopOwnerMainPageState extends State<ShopOwnerMainPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getPage(int index) {
    if (index == 0) {
      // Home content
      return Column(
        children: [
          Container(
            height: 200,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green[400],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Now', style: GoogleFonts.poppins(fontSize: 20)),
                        const SizedBox(height: 5),
                        Text('26°', style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Icon(Icons.cloud, color: Colors.white),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_pin, color: Colors.red),
                        Text('Anuradhapura', style: GoogleFonts.poppins(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      Text('Hi, ${widget.email}!', style: GoogleFonts.poppins(fontSize: 20)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  buildButton(context, 'Farmers List'),
                  const SizedBox(height: 50),
                  buildButton(context, 'Order Request'),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (index == 1) {
      // Show ChatbotPage
      return const ChatbotPage();
    } else if (index == 2) {
      // Show ProfilePage
      return const ProfilePage();
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _getPage(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.green[400],
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'Ask me'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget buildButton(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        height: 70,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            if (text == 'Farmers List') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FarmersListPage()),
              );
            } else if (text == 'Order Request') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderRequestsPage()),
              );
            }
          },
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}


