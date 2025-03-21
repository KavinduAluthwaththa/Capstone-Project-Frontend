import 'package:capsfront/enums/User_Types.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                child: CupertinoButton.filled(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  onPressed: _registerUser,
                  borderRadius: BorderRadius.circular(8.0),
                  child: const Text('Register'),
                ),
              ),
            ],
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
      print('User Registered: ${_firstNameController.text}, Type: ${_selectedUserType.toString()}');
    }
  }
}
