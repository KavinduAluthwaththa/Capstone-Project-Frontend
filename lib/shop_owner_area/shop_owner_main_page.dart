import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/shop_owner_area/FarmersList.dart';
import 'package:capsfront/shop_owner_area/MyOrders.dart';
import 'package:capsfront/shared/Chatbot.dart';
import 'package:capsfront/shared/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShopOwnerMainPage extends StatefulWidget {
  final String email;
  const ShopOwnerMainPage({super.key, required this.email});

  @override
  State<ShopOwnerMainPage> createState() => _ShopOwnerMainPageState();
}

class _ShopOwnerMainPageState extends State<ShopOwnerMainPage> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _shopDetails;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchShopDetails();
  }

  Future<void> _fetchShopDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.getShopByEmail(widget.email)), // Replace with your API endpoint
      );

      if (response.statusCode == 200) {
        setState(() {
          _shopDetails = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load shop details');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getPage(int index) {
    if (index == 0) {
      return Column(
        children: [
          // Weather and Greeting Section
          Container(
            height: 220,
            padding: const EdgeInsets.all(16),
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
                        Text(
                          DateFormat('EEEE, MMM d').format(DateTime.now()),
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '26°',
                              style: GoogleFonts.poppins(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.cloud, color: Colors.white, size: 24),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_pin, color: Colors.red),
                            const SizedBox(width: 4),
                            Text(
                              'Anuradhapura',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Hi, ${widget.email}!',
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const CircularProgressIndicator()
                else if (_errorMessage != null)
                  Text(
                    'Error: $_errorMessage',
                    style: const TextStyle(color: Colors.red),
                  )
                else if (_shopDetails != null)
                  Text(
                    'Shop Name: ${_shopDetails!['name']}\n'
                    'Location: ${_shopDetails!['location']}',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
              ],
            ),
          ),
          // Main Content with Buttons
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      'Farmers List',
                      Icons.people,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FarmersListPage()),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildActionButton(
                      'My Orders',
                      Icons.shopping_cart,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyRequestsPage(shopID:_shopDetails?['shopID'])),
                      ),
                    ),
                  ],
                ),
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

  Widget _buildActionButton(String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}