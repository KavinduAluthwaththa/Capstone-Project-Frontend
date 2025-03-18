import 'package:capsfront/admin_area/admin_main_page.dart';
import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/constraints/token_handler.dart';
import 'package:capsfront/models/register_model.dart';
import 'package:capsfront/users_area/farmer_main_page.dart';
import 'package:capsfront/users_area/inspector_main_page.dart';
import 'package:capsfront/users_area/shop_owner_main_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../enums/User_Types.dart'; // Adjust the import path accordingly

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  UserTypes? _selectedUserType;
  List<UserTypes> userTypes = UserTypes.values;

  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      final registerData = RegisterModel(
        userName: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        confirmedPassword: _confirmPasswordController.text.trim(),
        userTypes: _selectedUserType!.index,
      );

      try {
        final response = await http.post(
          Uri.parse(ApiEndpoints.registerUser),
          headers: {"Content-Type": "application/json; charset=UTF-8"},
          body: jsonEncode(registerData.toJson()),
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

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) => value!.isEmpty ? 'Enter your first name' : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) => value!.isEmpty ? 'Enter your last name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.contains('@') ? null : 'Enter a valid email',
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
              ),
              DropdownButtonFormField<UserTypes>(
                decoration: InputDecoration(labelText: 'User Type'),
                value: _selectedUserType,
                onChanged: (newValue) {
                  setState(() {
                    _selectedUserType = newValue;
                  });
                },
                items: userTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getUserTypeLabel(type)),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Select a user type' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Handle registration logic here
                    print('User Registered: ${_firstNameController.text}, Type: ${userTypesToJson(_selectedUserType!)}');
                  }
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getUserTypeLabel(UserTypes type) {
    switch (type) {
      case UserTypes.farmer:
        return 'Farmer';
      case UserTypes.inspector:
        return 'Inspector';
      case UserTypes.shopOwner:
        return 'Shop Owner';
      default:
        return 'Unknown';
    }
  }
}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}