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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isLoading = false;

  UserTypes? _selectedUserType;
  final List<UserTypes> _userTypes = UserTypes.values;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
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
                    _phoneController,
                    'Phone Number',
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
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
                    onChanged: _isLoading ? null : (newValue) => setState(() => _selectedUserType = newValue),
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
                      onPressed: _isLoading ? null : _registerUser,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Register',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  TextButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
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
      enabled: !_isLoading,
      validator: validator ?? (value) => (value == null || value.isEmpty) ? 'Please enter your $labelText' : null,
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(value) ? null : 'Please enter a valid email address';
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your phone number';
    
    // Remove any non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if phone number has 10-15 digits (international format)
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Phone number must be 10-15 digits';
    }
    
    return null;
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
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)), 
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)), 
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> submitForm() async {
    setState(() {
      _isLoading = true;
    });

    final registerData = {
      "firstName": _firstNameController.text.trim(),
      "lastName": _lastNameController.text.trim(),
      "userName": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
      "confirmedPassword": _confirmPasswordController.text.trim(),
      "phoneNumber": _phoneController.text.trim(),
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
        print("✅ Registration Successful.");
        _showSuccess("Registration successful! Please login to continue.");
        
        // Navigate to login page after successful registration
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? "Registration failed.";
        _showError(errorMessage);
      }

    } catch (e) {
      _showError("An unexpected error occurred: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}