import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/farmer_area/MarketPrice.dart';
import 'package:capsfront/farmer_area/ShopList.dart';
import 'package:capsfront/farmer_area/crops.dart';
import 'package:capsfront/models/farmer_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Your imports...

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

  @override
  void initState() {
    super.initState();
    _fetchFarmerData();
  }

  Future<void> _fetchFarmerData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      


    final email = Uri.encodeComponent(widget.email);
    
      final response = await http.get(
        Uri.parse(ApiEndpoints.getFarmer(email)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _currentFarmer = Farmer.fromJson(data);
          _fetchWeatherData(_currentFarmer!.farmLocation);
        });
      } else {
        throw Exception('Failed to load farmer data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherData(String location) async {
    const apiKey = 'cdedb0023ef6210f81913fa963239f7f';
    try {
      final response = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$location&units=metric&appid=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _temperature = '${data['main']['temp'].round()}°';
          _humidity = '${data['main']['humidity']}%';
          _weatherIcon = _getWeatherIcon(data['weather'][0]['id']);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Weather data unavailable';
        _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Weather Header Section
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildActionButton(
                                'My Crops',
                                Icons.grass,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CropsPage()),
                                ),
                              ),
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
                              _buildActionButton(
                                'Market Prices',
                                Icons.attach_money,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MarketPriceScreen()),
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    ); // <-- FIXED: Closing parenthesis and brace for Scaffold
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
