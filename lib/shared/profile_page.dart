import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/farmer_area/MyOrders.dart';
import 'package:capsfront/models/farmer_model.dart';
import 'package:capsfront/models/shop_model.dart';
import 'package:capsfront/shared/settings.dart';
import 'package:capsfront/accounts/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final int _selectedIndex = 2;
  bool _isLoading = true;
  String? _errorMessage;
  String? _userType;
  String? _userEmail;
  Farmer? _farmer;
  Shop? _shop;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Debug: Print all available keys
      print('Available SharedPreferences keys: ${prefs.getKeys()}');
      
      final token = prefs.getString('auth_token');
      final userType = prefs.getString('user_type');
      final userEmail = prefs.getString('user_email');
      
      // Debug: Print session data
      print('Token: $token');
      print('User Type: $userType');
      print('User Email: $userEmail');

      // Check for missing session data
      if (token == null || token.isEmpty) {
        await _handleSessionExpired('Authentication token not found');
        return;
      }
      
      if (userType == null || userType.isEmpty) {
        await _handleSessionExpired('User type not found');
        return;
      }
      
      if (userEmail == null || userEmail.isEmpty) {
        await _handleSessionExpired('User email not found');
        return;
      }

      setState(() {
        _userType = userType;
        _userEmail = userEmail;
      });

      if (userType.toLowerCase() == 'farmer') {
        await _loadFarmerProfile(userEmail, token);
      } else if (userType.toLowerCase() == 'shopowner') {
        await _loadShopProfile(userEmail, token);
      } else {
        throw Exception('Unknown user type: $userType');
      }
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSessionExpired(String reason) async {
    print('Session expired: $reason');
    
    // Clear all session data
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // Show dialog and navigate to login
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

  Future<void> _loadFarmerProfile(String email, String token) async {
    try {
      final encodedEmail = Uri.encodeComponent(email);
      print('Loading farmer profile for: $encodedEmail');
      
      final response = await http.get(
        Uri.parse(ApiEndpoints.getFarmer(encodedEmail)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Farmer API response status: ${response.statusCode}');
      print('Farmer API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _farmer = Farmer.fromJson(data);
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        await _handleSessionExpired('Authentication failed');
      } else {
        throw Exception('Failed to load farmer profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error loading farmer profile: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadShopProfile(String email, String token) async {
    try {
      final encodedEmail = Uri.encodeComponent(email);
      print('Loading shop profile for: $encodedEmail');
      
      final response = await http.get(
        Uri.parse(ApiEndpoints.getShopByEmail(encodedEmail)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Shop API response status: ${response.statusCode}');
      print('Shop API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _shop = Shop.fromJson(data);
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        await _handleSessionExpired('Authentication failed');
      } else {
        throw Exception('Failed to load shop profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error loading shop profile: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildProfileContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
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
              'Error loading profile',
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
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadUserProfile,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[400],
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Login Again'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildProfileOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    String name = '';
    String email = '';
    String location = '';
    String userId = '';

    if (_farmer != null) {
      name = _farmer!.name;
      email = _farmer!.Email;
      location = _farmer!.farmLocation;
      userId = 'ID: ${_farmer!.farmerID}';
    } else if (_shop != null) {
      name = _shop!.name;
      email = _shop!.email;
      location = _shop!.location;
      userId = 'ID: ${_shop!.shopID}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[400],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            name.isNotEmpty ? name : 'User Name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            email.isNotEmpty ? email : 'user@gmail.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: Colors.black54,
              ),
              const SizedBox(width: 4),
              Text(
                location.isNotEmpty ? location : 'Location',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              userId,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Column(
      children: [
        if (_farmer != null) ...[
          ProfileOption(
            icon: Icons.receipt_long,
            title: "My Orders",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyOrdersPage()),
              );
            },
          ),
          ProfileOption(
            icon: Icons.grass,
            title: "My Crops",
            onTap: () {
              // Navigate to crops page
            },
          ),
        ],
        if (_shop != null) ...[
          ProfileOption(
            icon: Icons.inventory,
            title: "My Inventory",
            onTap: () {
              // Navigate to inventory page
            },
          ),
          ProfileOption(
            icon: Icons.shopping_cart,
            title: "Requests",
            onTap: () {
              // Navigate to requests page
            },
          ),
        ],
        ProfileOption(
          icon: Icons.settings,
          title: "Settings",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
        ),
        ProfileOption(
          icon: Icons.help_outline,
          title: "Help & Support",
          onTap: () {
            // Navigate to help page
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _buildProfileContent()),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.green[700]),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.black38,
            size: 16,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}