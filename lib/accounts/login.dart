import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/models/login_model.dart';
import 'package:capsfront/farmer_area/farmer_main_page.dart';
import 'package:capsfront/shop_owner_area/shop_owner_main_page.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      final loginData = LoginModel(
        userName: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      try {
        final response = await http.post(
          Uri.parse(ApiEndpoints.loginUser),
          headers: {"Content-Type": "application/json", "Accept": "application/json"},
          body: jsonEncode(loginData.toJson()),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final jsonData = json.decode(response.body);
          final token = jsonData['token'];
          await SharedPreferences.getInstance().then((prefs) {
            prefs.setString('auth_token', token); // Save token
            });
            
          if (token == null || token.isEmpty) {
            _showError("Invalid token received.");
            return;
          }

          final decodedToken = JwtDecoder.decode(token);
          if (!decodedToken.containsKey('Role')) {
            _showError("User role not found.");
            return;
          }

          var role = decodedToken['Role'];
          String email = _emailController.text.trim();

          if (role is String) {
            switch (role.toLowerCase()) {
              case "farmer":
                role = 0;
                break;
              case "shopowner":
                role = 1;
                break;
              default:
                _showError("Unknown role: $role");
                return;
            }
          }

          _navigateToDashboard(role, email);
        } else {
          _showError("Login failed. Please check your credentials.");
        }
      } catch (e) {
        _showError("An error occurred: $e");
      }
    }
  }

  void _navigateToDashboard(int role, String email) {
    Widget? nextPage;
    switch (role) {
      case 0:
        nextPage = FarmerMainPage(email: email);
        break;
      case 1:
        nextPage = ShopOwnerMainPage(email: email);
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
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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
              Text('Login', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800)),
              SizedBox(height: 50),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Enter Username' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter Password';
                  if (value.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  onPressed: submitForm,
                  child: Text('Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text('Create an Account', style: TextStyle(fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: LoginPage()));
}
