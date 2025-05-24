import 'package:capsfront/farmer_area/Fertilizer_Reccomendation.dart';
import 'package:capsfront/farmer_area/MarketPrice.dart';
import 'package:capsfront/farmer_area/ShopList.dart';
import 'package:capsfront/farmer_area/Crops.dart';
import 'package:capsfront/shared/Chatbot.dart';
import 'package:capsfront/shared/DiseasesM.dart';
import 'package:capsfront/shared/Fertilizing.dart';
import 'package:capsfront/shared/profile_page.dart';
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
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const FarmerMainPage(email: 'example@example.com'),
    );
  }
}

class FarmerMainPage extends StatefulWidget {
  final String email;
  const FarmerMainPage({super.key, required this.email});

  @override
  State<FarmerMainPage> createState() => _FarmerMainPageState();
}

class _FarmerMainPageState extends State<FarmerMainPage> {
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
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  buildButton('My Crops'),
                  const SizedBox(height: 10),
                  buildButton('Shop List'),
                  const SizedBox(height: 10),
                  buildButton('Market Prices'),
                  const SizedBox(height: 10),
                  buildButton('Crop prediction'),
                  const SizedBox(height: 10),
                  buildButton('Diseases management'),
                  const SizedBox(height: 10),
                  buildButton('Fertilizer recommendation'),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (index == 1) {
      return const ChatbotPage();
    } else if (index == 2) {
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

  Widget buildButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        height: 70,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            if (text == 'My Crops') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CropsPage()),
              );
            } else if (text == 'Shop List') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShopListPage()),
              );
            } else if (text == 'Market Prices') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MarketPriceScreen()),
              );
            }
            else if (text == 'Crop prediction') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MarketPriceScreen()),
              );
            }
            else if (text == 'Diseases management') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DiseaseM()),
              );
            }
            else if (text == 'Fertilizer recommendation') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  Fertilizing()),
              );
            }
          },
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}