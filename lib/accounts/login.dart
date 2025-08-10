import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/models/login_model.dart';
import 'package:capsfront/farmer_area/FarmerMainPage.dart';
import 'package:capsfront/shop_owner_area/ShopMainPage.dart';
import 'package:capsfront/accounts/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> testBasicConnectivity() async {
    try {
      print('Testing basic connectivity...');
      print('Base URL: ${ApiEndpoints.baseUrl}');
      
      // Test 1: Swagger page
      final testUrl = '${ApiEndpoints.baseUrl.replaceAll('/api', '')}/swagger';
      print('Testing Swagger URL: $testUrl');
      
      final swaggerResponse = await http.get(Uri.parse(testUrl));
      print('Swagger test - Status: ${swaggerResponse.statusCode}');
      
      // Test 2: Login endpoint with GET (should return Method Not Allowed)
      print('Testing Login URL: ${ApiEndpoints.loginUser}');
      final loginResponse = await http.get(Uri.parse(ApiEndpoints.loginUser));
      print('Login endpoint test - Status: ${loginResponse.statusCode}');
      print('Login endpoint test - Body: ${loginResponse.body}');
      
      if (swaggerResponse.statusCode == 200) {
        print('✅ Swagger connectivity works');
      } else {
        print('❌ Swagger connectivity failed');
      }
      
      // 405 Method Not Allowed is expected for GET on login endpoint
      if (loginResponse.statusCode == 405 || loginResponse.statusCode == 404) {
        print('✅ Login endpoint is reachable (${loginResponse.statusCode})');
      } else {
        print('❌ Login endpoint test unexpected status: ${loginResponse.statusCode}');
      }
      
    } catch (e) {
      print('❌ Connectivity test error: $e');
    }
  }

  Future<void> submitForm() async {
    // First, let's test basic connectivity
    await testBasicConnectivity();
    
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final loginData = LoginModel(
        userName: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      try {
        print('Login URL: ${ApiEndpoints.loginUser}');
        print('Request body: ${jsonEncode(loginData.toJson())}');
        
        final response = await http.post(
          Uri.parse(ApiEndpoints.loginUser),
          headers: {"Content-Type": "application/json", "Accept": "application/json"},
          body: jsonEncode(loginData.toJson()),
        );

        print('Response status: ${response.statusCode}');
        print('Response headers: ${response.headers}');
        print('Response body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final jsonData = json.decode(response.body);
          final token = jsonData['token'];
          
          if (token == null || token.isEmpty) {
            _showError("Invalid token received.");
            return;
          }

          // Decode token to get user information
          final decodedToken = JwtDecoder.decode(token);
          
          if (!decodedToken.containsKey('Role')) {
            _showError("User role not found in token.");
            return;
          }

          // Extract user data from token
          var role = decodedToken['Role'];
          String email = _emailController.text.trim();
          String? userId = decodedToken['nameid']?.toString(); // User ID from token
          String? userName = decodedToken['unique_name']; // Username from token
          
          // Convert role to standard format
          String userType;
          int roleNumber;
          
          if (role is String) {
            switch (role.toLowerCase()) {
              case "farmer":
                userType = "farmer";
                roleNumber = 0;
                break;
              case "shopowner":
                userType = "shopowner";
                roleNumber = 1;
                break;
              default:
                _showError("Unknown role: $role");
                return;
            }
          } else {
            _showError("Invalid role format in token.");
            return;
          }

          // Save all important data to SharedPreferences
          await _saveUserSession(
            token: token,
            userType: userType,
            email: email,
            userId: userId,
            userName: userName,
            decodedToken: decodedToken,
          );

          // Navigate to appropriate dashboard
          _navigateToDashboard(roleNumber, email);
        } else {
          // Check if response body is not empty before decoding
          if (response.body.isNotEmpty) {
            try {
              final errorData = json.decode(response.body);
              String errorMessage = errorData['message'] ?? "Login failed. Please check your credentials.";
              _showError(errorMessage);
            } catch (e) {
              _showError("Login failed. Invalid response from server.");
            }
          } else {
            // Handle empty response (e.g., Unauthorized with no body)
            _showError("Login failed. Please check your credentials.");
          }
        }
      } catch (e) {
        print('Network error: $e');
        _showError("Network error: $e");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveUserSession({
    required String token,
    required String userType,
    required String email,
    String? userId,
    String? userName,
    required Map<String, dynamic> decodedToken,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save essential user session data
      await prefs.setString('auth_token', token);
      await prefs.setString('user_type', userType);
      await prefs.setString('user_email', email);
      
      // Save additional user data if available
      if (userId != null) {
        await prefs.setString('user_id', userId);
      }
      
      if (userName != null) {
        await prefs.setString('user_name', userName);
      }
      
      // Save login timestamp
      await prefs.setString('login_timestamp', DateTime.now().toIso8601String());
      
      // Save token expiration if available
      if (decodedToken.containsKey('exp')) {
        final expTimestamp = decodedToken['exp'];
        if (expTimestamp is int) {
          final expDate = DateTime.fromMillisecondsSinceEpoch(expTimestamp * 1000);
          await prefs.setString('token_expiry', expDate.toIso8601String());
        }
      }
      
      // Save additional token claims that might be useful
      if (decodedToken.containsKey('iss')) {
        await prefs.setString('token_issuer', decodedToken['iss'].toString());
      }
      
      if (decodedToken.containsKey('aud')) {
        await prefs.setString('token_audience', decodedToken['aud'].toString());
      }
      
      await prefs.setInt('user_role_number', userType == 'farmer' ? 0 : 1);
      
      await prefs.setBool('is_logged_in', true);
      
    } catch (e) {
      print('Error saving user session: $e');
      _showError("Failed to save user session. Please try again.");
    }
  }

  void _navigateToDashboard(int role, String email) {
    Widget? nextPage;
    switch (role) {
      case 0:
        nextPage = FarmerMainPage();
        break;
      case 1:
        nextPage = ShopOwnerMainPage();
        break;
      default:
        _showError("Unauthorized role: $role");
        return;
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => nextPage!),
      (route) => false,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Login',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 50),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Username/Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Enter Username/Email' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter Password';
                  if (value.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _isLoading ? null : submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Login',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text(
                  'Create an Account',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}