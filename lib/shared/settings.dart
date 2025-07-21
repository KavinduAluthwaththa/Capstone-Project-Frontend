import 'package:capsfront/accounts/login.dart';
import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/shared/PrivacyPolicyPage.dart';
import 'package:capsfront/shared/HelpSupport.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoggingOut = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String _errorMessage = '';

  // User data from SharedPreferences
  String? _userName;
  String? _userEmail;
  String? _userType;
  String? _userPhone;
  String? _userLocation;
  int? _userId;
  String? _authToken;

  // Controllers for editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        // Authentication
        _authToken = prefs.getString('auth_token');

        // Basic user info
        _userName =
            prefs.getString('user_name') ??
            prefs.getString('farmer_name') ??
            prefs.getString('shop_name');
        _userEmail =
            prefs.getString('user_email') ??
            prefs.getString('farmer_email') ??
            prefs.getString('shop_email');
        _userType = prefs.getString('user_type');
        _userPhone =
            prefs.getString('farmer_phone') ?? prefs.getString('shop_phone');
        _userLocation =
            prefs.getString('farmer_location') ??
            prefs.getString('shop_location');

        // User ID
        _userId =
            prefs.getInt('user_id') ??
            prefs.getInt('farmer_id') ??
            prefs.getInt('shop_id');

        // Set controller values
        _nameController.text = _userName ?? '';
        _emailController.text = _userEmail ?? '';
        _phoneController.text = _userPhone ?? '';
        _locationController.text = _userLocation ?? '';

        _isLoading = false;
      });

      print('User data loaded successfully');
      print('User ID: $_userId, Type: $_userType');
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _errorMessage = 'Failed to load user data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserProfile() async {
    if (_authToken == null || _userId == null || _userType == null) {
      _showErrorSnackBar('Missing authentication data. Please log in again.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String endpoint;
      Map<String, dynamic> requestData;

      if (_userType == 'farmer') {
        endpoint = ApiEndpoints.updateFarmer(_userId!.toString());
        requestData = {
          "farmerName": _nameController.text.trim(),
          "farmerEmail": _emailController.text.trim(),
          "farmerPhone": _phoneController.text.trim(),
          "farmerLocation": _locationController.text.trim(),
        };
      } else if (_userType == 'shopowner') {
        endpoint = ApiEndpoints.updateShop(_userId!.toString());
        requestData = {
          "shopName": _nameController.text.trim(),
          "shopEmail": _emailController.text.trim(),
          "shopPhone": _phoneController.text.trim(),
          "shopLocation": _locationController.text.trim(),
        };
      } else {
        throw Exception('Unknown user type: $_userType');
      }

      print('Updating profile with endpoint: $endpoint');
      print('Request data: $requestData');

      final response = await http.put(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode(requestData),
      );

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      if (response.statusCode == 200) {
        // Update successful, save to local storage
        await _saveUpdatedDataLocally();
        _showSuccessSnackBar('Profile updated successfully!');

        // Reload user data to reflect changes
        await _loadUserData();
      } else if (response.statusCode == 401) {
        await _handleSessionExpired('Authentication failed during update');
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to update profile';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error updating profile: $e');
      _showErrorSnackBar('Error updating profile: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _saveUpdatedDataLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Update the in-memory values
      setState(() {
        _userName = _nameController.text.trim();
        _userEmail = _emailController.text.trim();
        _userPhone = _phoneController.text.trim();
        _userLocation = _locationController.text.trim();
      });

      // Save general user data
      await prefs.setString('user_name', _nameController.text.trim());
      await prefs.setString('user_email', _emailController.text.trim());

      // Save based on user type
      if (_userType == 'farmer') {
        await prefs.setString('farmer_name', _nameController.text.trim());
        await prefs.setString('farmer_email', _emailController.text.trim());
        await prefs.setString('farmer_phone', _phoneController.text.trim());
        await prefs.setString(
          'farmer_location',
          _locationController.text.trim(),
        );
      } else if (_userType == 'shopowner') {
        await prefs.setString('shop_name', _nameController.text.trim());
        await prefs.setString('shop_email', _emailController.text.trim());
        await prefs.setString('shop_phone', _phoneController.text.trim());
        await prefs.setString('shop_location', _locationController.text.trim());
      }

      // Update last activity
      await prefs.setString(
        'last_activity_time',
        DateTime.now().toIso8601String(),
      );

      print('Updated data saved locally');
    } catch (e) {
      print('Error saving updated data locally: $e');
    }
  }

  Future<void> _handleSessionExpired(String reason) async {
    print('Session expired: $reason');

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              'Session Expired',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Your session has expired. Please log in again.\n\nReason: $reason',
              style: GoogleFonts.poppins(),
            ),
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
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(
                    color: Colors.green[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _showEditProfileDialog() async {
    // Reset controllers to current values before showing dialog
    _nameController.text = _userName ?? '';
    _emailController.text = _userEmail ?? '';
    _phoneController.text = _userPhone ?? '';
    _locationController.text = _locationController.text;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(
                'Edit Profile',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildEditField('Name', _nameController, Icons.person),
                    const SizedBox(height: 16),
                    _buildEditField('Email', _emailController, Icons.email),
                    const SizedBox(height: 16),
                    _buildEditField('Phone', _phoneController, Icons.phone),
                    const SizedBox(height: 16),
                    _buildEditField(
                      'Location',
                      _locationController,
                      Icons.location_on,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                  onPressed: () {
                    // Reset controllers to original values
                    _nameController.text = _userName ?? '';
                    _emailController.text = _userEmail ?? '';
                    _phoneController.text = _userPhone ?? '';
                    _locationController.text = _userLocation ?? '';
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  onPressed:
                      _isSaving
                          ? null
                          : () async {
                            if (_validateInputs()) {
                              Navigator.of(context).pop();
                              await _updateUserProfile();
                            }
                          },
                  child:
                      _isSaving
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.green[700]!,
                              ),
                            ),
                          )
                          : Text(
                            'Save',
                            style: GoogleFonts.poppins(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _validateInputs() {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Name cannot be empty');
      return false;
    }
    if (_emailController.text.trim().isEmpty) {
      _showErrorSnackBar('Email cannot be empty');
      return false;
    }
    if (!_emailController.text.trim().contains('@')) {
      _showErrorSnackBar('Please enter a valid email address');
      return false;
    }
    return true;
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[400]),
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[400]!),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      style: GoogleFonts.poppins(),
      keyboardType:
          label == 'Email'
              ? TextInputType.emailAddress
              : label == 'Phone'
              ? TextInputType.phone
              : TextInputType.text,
    );
  }

  Future<void> _logout() async {
    final shouldLogout =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(
                'Log Out',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Are you sure you want to log out? All local data will be cleared.',
                style: GoogleFonts.poppins(),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text(
                    'Log Out',
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;

    if (shouldLogout) {
      setState(() => _isLoggingOut = true);

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Show logout success message
        if (mounted) {
          _showSuccessSnackBar('Logged out successfully');
        }
      } catch (e) {
        print('Error during logout: $e');
        if (mounted) {
          _showErrorSnackBar('Error during logout: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoggingOut = false);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.green[400],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.red[400],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _getUserTypeDisplayName() {
    switch (_userType?.toLowerCase()) {
      case 'farmer':
        return 'Farmer';
      case 'shopowner':
        return 'Shop Owner';
      default:
        return _userType ?? 'User';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_errorMessage.isNotEmpty) _buildErrorBanner(),
            Expanded(
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        ),
                      )
                      : SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildAccountInfo(),
                            const SizedBox(height: 20),
                            _buildSettingsSection(),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green[200]!.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () => Navigator.maybePop(context),
              ),
              Expanded(
                child: Text(
                  "Settings",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Manage your account and preferences",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.red[100]!.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.error_outline, color: Colors.red, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage,
              style: GoogleFonts.poppins(color: Colors.red[700], fontSize: 14),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: Colors.red[600]),
            onPressed: () => setState(() => _errorMessage = ''),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Theme.of(context).cardTheme.color,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Account Information',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.edit, color: Colors.green[600], size: 20),
                    onPressed: _showEditProfileDialog,
                    tooltip: 'Edit Profile',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow('Name', _userName ?? 'Not set', Icons.person),
            const SizedBox(height: 16),
            _buildInfoRow('Email', _userEmail ?? 'Not set', Icons.email),
            const SizedBox(height: 16),
            _buildInfoRow('Phone', _userPhone ?? 'Not set', Icons.phone),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Location',
              _userLocation ?? 'Not set',
              Icons.location_on,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('User Type', _getUserTypeDisplayName(), Icons.badge),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.green[700], size: 20),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Theme.of(context).cardTheme.color,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            _buildSettingItem(
              icon: Icons.language,
              title: 'Language',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'English',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
              onTap: () {
                _showErrorSnackBar('Language selection coming soon!');
              },
            ),
            const Divider(height: 32),
            _buildSettingItem(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                );
              },
            ),
            const Divider(height: 32),
            _buildSettingItem(
              icon: Icons.help,
              title: 'Help & Support',
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpSupportPage()),
                );
              },
            ),
            const SizedBox(height: 32),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.green[700], size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[100]!, Colors.red[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!, width: 1),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.red[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        onPressed: _isLoggingOut ? null : _logout,
        child:
            _isLoggingOut
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red[700]!),
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Log Out',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}