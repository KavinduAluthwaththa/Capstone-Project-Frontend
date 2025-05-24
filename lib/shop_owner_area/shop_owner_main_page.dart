import 'package:capsfront/shop_owner_area/FarmersList.dart';
import 'package:capsfront/shop_owner_area/OrderRequest.dart';
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
      home: ShopOwnerMainPage(email: 'example@example.com'),
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
  int _selectedIndex = 0; // Default to "Home"

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Shop(
      shopOwnerEmail: widget.email,
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
    );
  }
}

class Shop extends StatelessWidget {
  final String shopOwnerEmail;
  final int selectedIndex;
  final Function(int) onItemTapped;

  const Shop({
    super.key,
    required this.shopOwnerEmail,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
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
                      Row(
                        children: [
                          const Icon(Icons.location_pin, color: Colors.red),
                          Text('Anuradhapura', style: GoogleFonts.poppins(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),// Pass context
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      children: [
                        Text('Hi, $shopOwnerEmail!', style: GoogleFonts.poppins(fontSize: 20)), // Display shop owner's email
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
                    buildButton(context, 'Farmers List'), // Pass context
                    const SizedBox(height: 50),
                    buildButton(context, 'Order Request'), // Pass context
                  ],
                ),
              ),
            ),
          ],
        ),
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


