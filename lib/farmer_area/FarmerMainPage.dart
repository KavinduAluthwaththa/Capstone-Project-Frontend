import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/farmer_area/CropSuggest.dart';
import 'package:capsfront/farmer_area/ShopList.dart';
import 'package:capsfront/farmer_area/MyCrops.dart';
import 'package:capsfront/models/farmer_model.dart';
import 'package:capsfront/shared/DiseaseIdentification.dart';
import 'package:capsfront/shared/FertilizerCalculation.dart';
import 'package:capsfront/shared/Chatbot.dart';         
import 'package:capsfront/shared/ProfilePage.dart'; 
import 'package:capsfront/accounts/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmerMainPage extends StatefulWidget { // Make email optional since we'll get it from SharedPreferences
  const FarmerMainPage({super.key});

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
  int _selectedIndex = 0;

  // Session data from SharedPreferences
  String? _authToken;
  String? _userType;
  String? _userEmail;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadSessionAndFetchData();
  }

  // Load session data from SharedPreferences
  Future<void> _loadSessionAndFetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        _authToken = prefs.getString('auth_token');
        _userType = prefs.getString('user_type');
        _userEmail = prefs.getString('user_email');
        _userName = prefs.getString('user_name');
      });

      print('Session data loaded:');

      // Validate session
      if (_authToken == null || _authToken!.isEmpty) {
        await _handleSessionExpired('Authentication token missing');
        return;
      }

      if (_userType != 'farmer') {
        await _handleSessionExpired('Invalid user type for farmer area');
        return;
      }

      // Load cached data first for immediate display
      await _loadCachedFarmerData();
      
      // Then fetch fresh data
      await _fetchFarmerData();
      
    } catch (e) {
      print('Error loading session data: $e');
      await _handleSessionExpired('Session error: $e');
    }
  }

  // Handle session expiry
  Future<void> _handleSessionExpired(String reason) async {
    print('Session expired: $reason');
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Session Expired'),
            content: Text('Your session has expired. Please log in again.\n\nReason: $reason'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  // Save farmer data to SharedPreferences
  Future<void> _saveFarmerDataToPrefs(Farmer farmer) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save farmer-specific data
      await prefs.setString('farmer_name', farmer.name);
      await prefs.setString('farmer_email', farmer.Email);
      await prefs.setString('farmer_location', farmer.farmLocation);
      await prefs.setInt('farmer_id', farmer.farmerID);
      await prefs.setString('farmer_phone', farmer.phoneNumber.toString());
      
      // Save weather data
      await prefs.setString('last_temperature', _temperature);
      await prefs.setString('last_humidity', _humidity);
      await prefs.setString('last_weather_icon', _weatherIcon);
      await prefs.setString('weather_location', farmer.farmLocation);
      await prefs.setString('weather_last_updated', DateTime.now().toIso8601String());
      
      print('Farmer data saved to SharedPreferences');
    } catch (e) {
      print('Error saving farmer data to SharedPreferences: $e');
    }
  }

  // Load cached farmer data from SharedPreferences
  Future<void> _loadCachedFarmerData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final cachedName = prefs.getString('farmer_name');
      final cachedEmail = prefs.getString('farmer_email');
      final cachedLocation = prefs.getString('farmer_location');
      final cachedId = prefs.getInt('farmer_id');
      final cachedPhone = prefs.getString('farmer_phone');
      
      if (cachedName != null && cachedEmail != null && cachedLocation != null && cachedId != null) {
        setState(() {
          _currentFarmer = Farmer(
            farmerID: cachedId,
            name: cachedName,
            Email: cachedEmail,
            farmLocation: cachedLocation,
            phoneNumber: cachedPhone != null ? int.tryParse(cachedPhone) ?? 0 : 0,
          );
          
          // Load cached weather data
          _temperature = prefs.getString('last_temperature') ?? '--°';
          _humidity = prefs.getString('last_humidity') ?? '--%';
          _weatherIcon = prefs.getString('last_weather_icon') ?? '☀️';
          
          _isLoading = false;
        });
        
        print('Loaded cached farmer data');
        
        // Check if weather data needs updating (if older than 30 minutes)
        final lastUpdated = prefs.getString('weather_last_updated');
        if (lastUpdated != null) {
          final lastUpdateTime = DateTime.parse(lastUpdated);
          final now = DateTime.now();
          if (now.difference(lastUpdateTime).inMinutes > 30) {
            _fetchWeatherData(cachedLocation);
          }
        }
      }
    } catch (e) {
      print('Error loading cached farmer data: $e');
    }
  }

  Future<void> _fetchFarmerData() async {
    try {
      if (_authToken == null || _authToken!.isEmpty) {
        throw Exception('No authentication token available');
      }
      
      final emailToUse = _userEmail;
      if (emailToUse == null || emailToUse.isEmpty) {
        throw Exception('No email available for farmer lookup');
      }
      
      final email = Uri.encodeComponent(emailToUse);
    
      final response = await http.get(
        Uri.parse(ApiEndpoints.getFarmer(email)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      print('Farmer API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final farmer = Farmer.fromJson(data);
        
        setState(() {
          _currentFarmer = farmer;
        });
        
        // Save farmer data to SharedPreferences
        await _saveFarmerDataToPrefs(farmer);
        
        // Fetch weather data
        await _fetchWeatherData(farmer.farmLocation);
        
      } else if (response.statusCode == 401) {
        await _handleSessionExpired('Authentication failed');
      } else {
        throw Exception('Failed to load farmer data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching farmer data: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherData(String location) async {
    final weatherApiKey = dotenv.env['weatherapi'];
    if (weatherApiKey == null || weatherApiKey.isEmpty) {
      setState(() {
        _errorMessage = 'Weather API key not configured';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$location,LK&units=metric&appid=$weatherApiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _temperature = '${data['main']['temp'].round()}°';
          _humidity = '${data['main']['humidity']}%';
          _weatherIcon = _getWeatherIcon(data['weather'][0]['id']);
          _isLoading = false;
          _errorMessage = '';
        });
        
        // Save updated weather data to SharedPreferences
        if (_currentFarmer != null) {
          await _saveFarmerDataToPrefs(_currentFarmer!);
        }
      } else {
        throw Exception('Weather API Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Weather data unavailable: ${e.toString()}';
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

  // Save app usage data
  Future<void> _saveAppUsageData(String feature) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usageKey = 'feature_usage_$feature';
      final currentCount = prefs.getInt(usageKey) ?? 0;
      await prefs.setInt(usageKey, currentCount + 1);
      await prefs.setString('last_used_feature', feature);
      await prefs.setString('last_activity_time', DateTime.now().toIso8601String());
      
      print('Usage tracked: $feature used ${currentCount + 1} times');
    } catch (e) {
      print('Error saving usage data: $e');
    }
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
                  'Hi, ${_currentFarmer?.name ?? _userName ?? 'Farmer'}!',
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Main Content with Buttons
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  )
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                _errorMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadSessionAndFetchData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[400],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildActionButton(
                                'My Crops',
                                Icons.grass,
                                () async {
                                  await _saveAppUsageData('my_crops');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const CropsPage()),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildActionButton(
                                'Shop List',
                                Icons.store,
                                () async {
                                  await _saveAppUsageData('shop_list');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const ShopListPage()),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildActionButton(
                                'Crop Suggestion',
                                Icons.android,
                                () async {
                                  await _saveAppUsageData('crop_suggestion');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const CropSuggest()),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildActionButton(
                                'Diseases Identification',
                                Icons.crop,
                                () async {
                                  await _saveAppUsageData('disease_identification');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const DiseaseM()),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildActionButton(
                                'Fertilizer Calculation',
                                Icons.medical_information,
                                () async {
                                  await _saveAppUsageData('fertilizer_calculation');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Fertilizing()),
                                  );
                                },
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
          elevation: 2,
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