import 'dart:convert';
import 'package:capsfront/accounts/register.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/constraints/token_handler.dart';
import 'package:capsfront/models/login_model.dart';
import 'package:capsfront/admin_area/admin_main_page.dart';
import 'package:capsfront/farmer_area/farmer_main_page.dart';
import 'package:capsfront/Inspector_area/inspector_main_page.dart';
import 'package:capsfront/shop_owner_area/shop_owner_main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
          headers: {"Content-Type": "application/json", 
          "Accept": "application/json"},
          body: jsonEncode(loginData.toJson()),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final jsonData = json.decode(response.body);
          final token = jsonData['token'];

          if (token == null || token.isEmpty) {
            _showError("Invalid token received.");
            return;
          }

          TokenHandler().addToken(token);
          final decodedToken = JwtDecoder.decode(token);

          if (!decodedToken.containsKey('role')) {
            _showError("User role not found.");
            return;
          }

          String role = decodedToken['role'];
          String email = _emailController.text.trim();

          _navigateToDashboard(role, email);
        } else {
          _showError("Login failed. Please check your credentials.");
        }
      } catch (e) {
        _showError("An error occurred: $e");
      }
    }
  }

  void _navigateToDashboard(String role, String email) {
    Widget nextPage;

    switch (role) {
      case "Admin":
        nextPage = AdminMainPage(email: email);
        break;
      case "Farmer":
        nextPage = FarmerMainPage(email: email);
        break;
      case "Inspector":
        nextPage = InspectorMainPage(email: email);
        break;
      case "ShopOwner":
        nextPage = ShopOwnerMainPage(email: email);
        break;
      default:
        _showError("Unauthorized role: $role");
        return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
          (Route<dynamic> route) => false,
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
            children: <Widget>[

              Text(
                'Login',
                style: TextStyle(fontSize: 40, color: Colors.black, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 50.0),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                ),
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Enter Username' : null,
              ),
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter Password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20.0),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50), // Fixed missing value
                  ),
                  onPressed: submitForm, // Corrected function call
                  child: Text('Login',
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 16.0),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()), // Fixed incorrect reference
                  );
                },
                child: Text(
                  'Create an Account',
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
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
