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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Shop(shopOwnerEmail: widget.email),
    );
  }
}

class Shop extends StatelessWidget {
  final String shopOwnerEmail;
  const Shop({super.key, required this.shopOwnerEmail});

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

  // Updated buildButton method with navigation support
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
                MaterialPageRoute(builder: (context) => const FarmersList()),
              );
            } else if (text == 'Order Request') {
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(content: Text('Order Request button clicked')),
              // );
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
              color: Colors.green.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Placeholder FarmersListPage
class FarmersListPage extends StatelessWidget {
  const FarmersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmers List'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text('This is the Farmers List page'),
      ),
    );
  }
}
