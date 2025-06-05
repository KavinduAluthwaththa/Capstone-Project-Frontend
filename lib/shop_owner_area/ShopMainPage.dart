import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/shop_owner_area/FarmersList.dart';
import 'package:capsfront/shared/Chatbot.dart';
import 'package:capsfront/shared/ProfilePage.dart';
import 'package:capsfront/accounts/login.dart';
import 'package:capsfront/models/shop_model.dart';
import 'package:capsfront/shop_owner_area/MyOrders.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ShopOwnerMainPage extends StatefulWidget {
  final String? email;
  const ShopOwnerMainPage({super.key, this.email});

  @override
  State<ShopOwnerMainPage> createState() => _ShopOwnerMainPageState();
}

class _ShopOwnerMainPageState extends State<ShopOwnerMainPage> {
  int _selectedIndex = 0;
  Shop? _currentShop;
  bool _isLoading = true;
  String _errorMessage = '';
  String _temperature = '--°';
  String _weatherIcon = '☀️';
  String _humidity = '--%';

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
      
      if (_authToken == null || _authToken!.isEmpty) {
        await _handleSessionExpired('Authentication token missing');
        return;
      }

      if (_userType != 'shopowner') {
        await _handleSessionExpired('Invalid user type for shop owner area');
        return;
      }

      // Load cached data first for immediate display
      await _loadCachedShopData();
      
      // Then fetch fresh data
      await _fetchShopData();
      
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              'Session Expired',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Your session has expired. Please log in again.\n\nReason: $reason',
              style: GoogleFonts.poppins(),
            ),
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
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(
                    color: Colors.green[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  // Save shop data to SharedPreferences
  Future<void> _saveShopDataToPrefs(Shop shop) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save shop-specific data
      await prefs.setString('shop_name', shop.name);
      await prefs.setString('shop_email', shop.email);
      await prefs.setString('shop_location', shop.location);
      await prefs.setInt('shop_id', shop.shopID);
      await prefs.setString('shop_phone', shop.phoneNumber);
      
      // Save weather data
      await prefs.setString('last_temperature', _temperature);
      await prefs.setString('last_humidity', _humidity);
      await prefs.setString('last_weather_icon', _weatherIcon);
      await prefs.setString('weather_location', shop.location);
      await prefs.setString('weather_last_updated', DateTime.now().toIso8601String());
      
      print('Shop data saved to SharedPreferences');
    } catch (e) {
      print('Error saving shop data to SharedPreferences: $e');
    }
  }

  // Load cached shop data from SharedPreferences
  Future<void> _loadCachedShopData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final cachedName = prefs.getString('shop_name');
      final cachedEmail = prefs.getString('shop_email');
      final cachedLocation = prefs.getString('shop_location');
      final cachedId = prefs.getInt('shop_id');
      final cachedPhone = prefs.getString('shop_phone');
      
      if (cachedName != null && cachedEmail != null && cachedLocation != null && cachedId != null) {
        setState(() {
          _currentShop = Shop(
            shopID: cachedId,
            name: cachedName,
            email: cachedEmail,
            location: cachedLocation,
            phoneNumber: cachedPhone ?? '',
          );
          
          // Load cached weather data
          _temperature = prefs.getString('last_temperature') ?? '--°';
          _humidity = prefs.getString('last_humidity') ?? '--%';
          _weatherIcon = prefs.getString('last_weather_icon') ?? '☀️';
          
          _isLoading = false;
        });
        
        print('Loaded cached shop data');
        
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
      print('Error loading cached shop data: $e');
    }
  }

  Future<void> _fetchShopData() async {
    try {
      if (_authToken == null || _authToken!.isEmpty) {
        throw Exception('No authentication token available');
      }
      
      // Use email from SharedPreferences, fallback to widget.email
      final emailToUse = _userEmail ?? widget.email;
      if (emailToUse == null || emailToUse.isEmpty) {
        throw Exception('No email available for shop lookup');
      }
      
      final email = Uri.encodeComponent(emailToUse);
    
      final response = await http.get(
        Uri.parse(ApiEndpoints.getShopByEmail(email)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      print('Shop API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final shop = Shop.fromJson(data);
        
        setState(() {
          _currentShop = shop;
        });
        
        // Save shop data to SharedPreferences
        await _saveShopDataToPrefs(shop);
        
        // Fetch weather data
        await _fetchWeatherData(shop.location);
        
      } else if (response.statusCode == 401) {
        await _handleSessionExpired('Authentication failed');
      } else {
        throw Exception('Failed to load shop data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching shop data: $e');
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
        if (_currentShop != null) {
          await _saveShopDataToPrefs(_currentShop!);
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getPage(int index) {
    if (index == 0) {
      return Column(
        children: [
          _buildHeader(),
          // Main Content with Buttons
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  )
                : _errorMessage.isNotEmpty
                    ? _buildErrorState()
                    : _buildMainContent(),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green[200]!.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date and Time Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                DateFormat('EEEE, MMM d, yyyy').format(DateTime.now()),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Weather and Location Section
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weather Info
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _weatherIcon,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _temperature,
                                  style: GoogleFonts.poppins(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.water_drop,
                                      size: 14,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        _humidity,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Location Info
                    if (_currentShop != null) ...[
                      Flexible(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red[400],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentShop!.location,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome Back! 👋',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _currentShop?.name ?? _userName ?? 'Shop Owner',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.green[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Online & Ready for Business',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Oops! Something went wrong',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.green[600]!],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.green[300]!.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _loadSessionAndFetchData,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(
                'Try Again',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            _buildActionButton(
              'Farmers List',
              Icons.people,
              'Connect with local farmers',
              () async {
                await _saveAppUsageData('farmers_list');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FarmersListPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildActionButton(
              'My Orders',
              Icons.shopping_cart,
              'Manage your crop orders',
              () async {
                await _saveAppUsageData('my_orders');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyRequestsPage(shopID: _currentShop?.shopID ?? 0)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _getPage(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          backgroundColor: Colors.green[400],
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'Ask me'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String title, IconData icon, String subtitle, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[400]!, Colors.green[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green[300]!.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.green[600],
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}