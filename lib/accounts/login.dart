import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/constraints/token_handler.dart';
import 'package:capsfront/models/login_model.dart';
import 'package:capsfront/admin_area/admin_main_page.dart';
import 'package:capsfront/users_area/farmer_main_page.dart';
import 'package:capsfront/users_area/inspector_main_page.dart';
import 'package:capsfront/users_area/shop_owner_main_page.dart';

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
          headers: {"Content-Type": "application/json; charset=UTF-8"},
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
        nextPage = AdminMainPage(email: email) as Widget;
        break;
      case "Farmer":
        nextPage = FarmerMainPage(email: email) as Widget;
        break;
      case "Inspector":
        nextPage = InspectorMainPage(email: email) as Widget;
        break;
      case "ShopOwner":
        nextPage = ShopOwnerMainPage(email: email) as Widget;
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
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Please enter your username' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: submitForm,
                child: const Text('Login'),
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
