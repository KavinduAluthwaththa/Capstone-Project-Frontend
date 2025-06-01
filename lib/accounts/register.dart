import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constraints/api_endpoint.dart';
import 'login.dart';

enum UserTypes { farmer, shopOwner }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

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
  final TextEditingController _locationController = TextEditingController();

  UserTypes? _selectedUserType;
  final List<UserTypes> _userTypes = UserTypes.values;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensures the keyboard doesn't cover fields
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min, // Prevents unnecessary expansion
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Register',
                    style: TextStyle(fontSize: 40, color: Colors.black, fontWeight: FontWeight.w800),
                  ),

                  const SizedBox(height: 50.0),

                  _buildTextField(_firstNameController, 'First Name'),
                  const SizedBox(height: 12.0),
                  _buildTextField(_lastNameController, 'Last Name'),
                  const SizedBox(height: 12.0),

                  _buildTextField(
                    _emailController,
                    'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),

                  const SizedBox(height: 12.0),
                  _buildTextField(
                    _passwordController,
                    'Password',
                    obscureText: true,
                    validator: (value) => value != null && value.length < 6
                        ? 'Password must be at least 6 characters'
                        : null,
                  ),

                  const SizedBox(height: 12.0),
                  _buildTextField(
                    _confirmPasswordController,
                    'Confirm Password',
                    obscureText: true,
                    validator: (value) => value != _passwordController.text
                        ? 'Passwords do not match'
                        : null,
                  ),

                    const SizedBox(height: 12.0),
                    _buildTextField(
                    _locationController,
                    'City',
                    keyboardType: TextInputType.text,
                    validator: (value) => (value == null || value.isEmpty) ? 'Please enter your Location' : null,
                    ),

                  const SizedBox(height: 12.0),
                  DropdownButtonFormField<UserTypes>(
                    decoration: const InputDecoration(
                      labelText: 'User Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    ),
                    value: _selectedUserType,
                    onChanged: (newValue) => setState(() => _selectedUserType = newValue),
                    items: _userTypes.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(_getUserTypeLabel(type)),
                    )).toList(),
                    validator: (value) => value == null ? 'Please select a user type' : null,
                  ),

                  const SizedBox(height: 16.0),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _registerUser,
                      child: Text(
                        'Register',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()), // Replace with actual screen
                      );
                    },
                    child: Text(
                      'Already have an account?',
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {TextInputType? keyboardType, bool obscureText = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator ?? (value) => (value == null || value.isEmpty) ? 'Please enter your $labelText' : null,
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(value) ? null : 'Please enter a valid email address';
  }

  String _getUserTypeLabel(UserTypes type) {
    switch (type) {
      case UserTypes.farmer:
        return 'Farmer';
      case UserTypes.shopOwner:
        return 'Shop Owner';
      }
  }

  void _registerUser() {
    if (_formKey.currentState!.validate()) {
      if (_selectedUserType == null) {
        _showError("Please select a user type.");
        return;
      }

      print('User Registered: ${_firstNameController.text}, Type: ${_selectedUserType.toString()}');
      submitForm();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
    );
  }

  Future<void> submitForm() async {
    final registerData = {
      "firstName": _firstNameController.text.trim(),
      "lastName": _lastNameController.text.trim(),
      "userName": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
      "confirmedPassword": _confirmPasswordController.text.trim(),
      "userTypes": _selectedUserType?.index,
      "address": _locationController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.registerUser),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode(registerData),
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // ✅ Registration is successful. No need to check for a token.
        print("✅ Registration Successful.");

        // Optionally, navigate to login or show a success message
      } else {
        // Extract error message from response
        final errorMessage = json.decode(response.body)['message'] ?? "Registration failed.";
        _showError(errorMessage);
      }

    } catch (e) {
      _showError("An unexpected error occurred: $e");
    }
  }
}
