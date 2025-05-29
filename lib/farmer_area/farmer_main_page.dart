import 'package:capsfront/farmer_area/MarketPrice.dart';
import 'package:capsfront/farmer_area/ShopList.dart';
import 'package:capsfront/farmer_area/Crops.dart';
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
      home: FarmerMainPage(email: 'example@example.com'),
    );
  }
} 

class FarmerMainPage extends StatefulWidget {
  final String email; // Or farmerName
  const FarmerMainPage({super.key, required this.email});

  @override
  State<FarmerMainPage> createState() => _FarmerMainPageState();
}

class _FarmerMainPageState extends State<FarmerMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 200,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green[400],
                borderRadius: BorderRadius.only(
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
                          SizedBox(height: 5),
                          Text('26°', style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Icon(Icons.cloud, color: Colors.white),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_pin, color: Colors.red),
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
            SizedBox(height: 50),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    buildButton('My Crops'),
                    SizedBox(height: 50),
                    buildButton('Shop List'),
                    SizedBox(height: 50),
                    buildButton('Market Prices'),
                  ],
                ),
              ),
            ),
          ],
        ),
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
                MaterialPageRoute(builder: (context) => CropsPage()),
              );
            } else if (text == 'Shop List') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShopListPage()),

              );
            } else if (text == 'Market Prices') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MarketPriceScreen()),
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