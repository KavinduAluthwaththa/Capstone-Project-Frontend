import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/farmer_area/CropSuggest.dart';
//import 'package:capsfront/farmer_area/MarketPrice.dart';
import 'package:capsfront/farmer_area/ShopList.dart';
import 'package:capsfront/farmer_area/MyCrops.dart';
import 'package:capsfront/models/farmer_model.dart';
import 'package:capsfront/shared/DiseaseIdentification.dart';
import 'package:capsfront/shared/FertilizerCalculation.dart';
import 'package:capsfront/shared/Chatbot.dart';         
//import 'package:capsfront/shared/profile_page.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FarmerMainPage extends StatefulWidget {
  final String email;
  const FarmerMainPage({super.key, required this.email});

  @override
  State<FarmerMainPage> createState() => _FarmerMainPageState();
}

class _FarmerMainPageState extends State<FarmerMainPage> {
  Farmer? _currentFarmer;
  bool _isLoading = true;
  String _errorMessage = '';
  String _temperature = '--°';
  String _weatherIcon = '☀️';
  String _humidity = '--%';

  int _selectedIndex = 0; // <-- Add this

  @override
  void initState() {
    super.initState();
    _fetchFarmerData();
  }

  // Fix 1: Move weatherApiKey to _fetchWeatherData method
Future<void> _fetchFarmerData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final email = Uri.encodeComponent(widget.email);

    print('Fetching farmer data for: $email');
    final response = await http.get(
      Uri.parse(ApiEndpoints.getFarmer(email)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Farmer API status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _currentFarmer = Farmer.fromJson(data);
      });
      // Only fetch weather if farmLocation is not empty
      if (_currentFarmer != null && _currentFarmer!.farmLocation.isNotEmpty) {
        await _fetchWeatherData(_currentFarmer!.farmLocation);
      }
      setState(() {
        _isLoading = false;
        _errorMessage = '';
      });
    } else {
      setState(() {
        _errorMessage = 'Failed to load farmer data: ${response.statusCode}';
        _isLoading = false;
      });
    }
  } catch (e) {
    print('Error fetching farmer data: $e');
    setState(() {
      _errorMessage = 'Error: ${e.toString()}';
      _isLoading = false;
    });
  }
}

// Fix 2: Add proper weather API key handling and error checking
Future<void> _fetchWeatherData(String location) async {
  if (!dotenv.isInitialized) {
    setState(() {
      _errorMessage = 'Environment not initialized';
      _isLoading = false;
    });
    return;
  }
  final weatherApiKey = dotenv.env['weatherapi'];
  if (weatherApiKey == null || weatherApiKey.isEmpty) {
    setState(() {
      _errorMessage = 'Weather API key not configured';
      _isLoading = false;
    });
    return;
  }

  try {
    print('Fetching weather for: $location');
    final response = await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$location,LK&units=metric&appid=$weatherApiKey'),
    );
    print('Weather API status: ${response.statusCode}');
    print('Weather API body: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _temperature = '${data['main']['temp'].round()}°';
        _humidity = '${data['main']['humidity']}%';
        _weatherIcon = _getWeatherIcon(data['weather'][0]['id']);
        _errorMessage = '';
      });
    } else {
      setState(() {
        _errorMessage = 'Weather API Error: ${response.statusCode}';
      });
    }
  } catch (e) {
    print('Error fetching weather data: $e');
    setState(() {
      _errorMessage = 'Weather data unavailable: ${e.toString()}';
    });
  }
}

  String _getWeatherIcon(int conditionCode) {
    if (conditionCode < 300) return '⛈️';
    if (conditionCode < 400) return '🌧️';
    if (conditionCode < 600) return '🌧️';
    if (conditionCode < 700) return '❄️';
    if (conditionCode < 800) return '🌫️';
    if (conditionCode == 800) return '☀️';
    if (conditionCode < 900) return '☁️';
    return '🌈';
  }

  Widget _getPage(int index) {
    if (index == 0) {
      return Column(
        children: [
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
                              _temperature,
                              style: GoogleFonts.poppins(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text(_weatherIcon,
                                style: const TextStyle(fontSize: 24)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.water_drop,
                                size: 16, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text('Humidity: $_humidity',
                                style: GoogleFonts.poppins(fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                    if (_currentFarmer != null) ...[
                      Column(
                        children: [
                          const Icon(Icons.location_pin, color: Colors.red),
                          const SizedBox(height: 4),
                          Text(
                            _currentFarmer!.farmLocation,
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Hi, ${_currentFarmer?.name ?? widget.email}!',
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Main Content with Buttons
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView( // <-- Add this
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // <-- Add this
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // _buildActionButton(
                              //   'My Crops',
                                //Icons.grass,
                                // () => Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) => CropsPage(farmerId: (_currentFarmer?.farmerID is int ? _currentFarmer!.farmerID : 0))),
                                // ),
                              //),
                              const SizedBox(height: 20),
                              _buildActionButton(
                                'Shop List',
                                Icons.store,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ShopListPage()),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // _buildActionButton(
                              //   'Crop Suggestion',
                              //   Icons.android,
                              //   () => Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => CropSuggest()),
                              //   ),
                              // ),
                              const SizedBox(height: 20),
                              _buildActionButton(
                                'Diseases Identification',
                                Icons.crop,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DiseaseM()),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildActionButton(
                                'Fertilizer Calculation',
                                Icons.medical_information,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Fertilizing()),
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
    // } else if (index == 2) {
    //   return const ProfilePage();
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
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'Ask me'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String text, IconData icon, VoidCallback onPressed) {
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
