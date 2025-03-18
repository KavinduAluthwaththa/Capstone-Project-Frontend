import 'package:capsfront/enums/User_Types.dart';
import 'package:flutter/material.dart';

class UserRegistrationScreen extends StatefulWidget {
  @override
  _UserRegistrationScreenState createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  UserTypes? _selectedUserType;
  final List<UserTypes> _userTypes = UserTypes.values;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
              _buildTextField(_firstNameController, 'First Name'),
              _buildTextField(_lastNameController, 'Last Name'),
              _buildTextField(
                _emailController,
                'Email',
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              _buildTextField(
                _passwordController,
                'Password',
                obscureText: true,
                validator: (value) => value != null && value.length < 6 ? 'Password must be at least 6 characters' : null,
              ),
              _buildTextField(
                _confirmPasswordController,
                'Confirm Password',
                obscureText: true,
                validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
              ),
              DropdownButtonFormField<UserTypes>(
                decoration: InputDecoration(labelText: 'User Type'),
                value: _selectedUserType,
                onChanged: (newValue) => setState(() => _selectedUserType = newValue),
                items: _userTypes.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(_getUserTypeLabel(type)),
                )).toList(),
                validator: (value) => value == null ? 'Please select a user type' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerUser,
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {TextInputType? keyboardType, bool obscureText = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator ?? (value) => (value == null || value.isEmpty) ? 'Please enter your $labelText' : null,
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\$');
    return emailRegex.hasMatch(value) ? null : 'Please enter a valid email address';
  }

  String _getUserTypeLabel(UserTypes type) {
    switch (type) {
      case UserTypes.farmer:
        return 'Farmer';
      case UserTypes.inspector:
        return 'Inspector';
      case UserTypes.shopOwner:
        return 'Shop Owner';
    }
  }

  void _registerUser() {
    if (_formKey.currentState!.validate()) {
      print('User Registered: ${_firstNameController.text}, Type: ${userTypesToJson(_selectedUserType!)}');
      _clearForm();
    }
  }

  void _clearForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() => _selectedUserType = null);
  }
}