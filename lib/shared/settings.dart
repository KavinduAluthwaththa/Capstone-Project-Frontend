import 'package:capsfront/accounts/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _isLoggingOut = false;
  bool _isLoading = true;
  String _errorMessage = '';

  // User data from SharedPreferences
  String? _userName;
  String? _userEmail;
  String? _userType;
  String? _userPhone;
  String? _userLocation;

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
        // Basic user info
        _userName = prefs.getString('user_name') ?? prefs.getString('farmer_name') ?? prefs.getString('shop_name');
        _userEmail = prefs.getString('user_email') ?? prefs.getString('farmer_email') ?? prefs.getString('shop_email');
        _userType = prefs.getString('user_type');
        _userPhone = prefs.getString('farmer_phone') ?? prefs.getString('shop_phone');
        _userLocation = prefs.getString('farmer_location') ?? prefs.getString('shop_location');

        // Set controller values
        _nameController.text = _userName ?? '';
        _emailController.text = _userEmail ?? '';
        _phoneController.text = _userPhone ?? '';
        _locationController.text = _userLocation ?? '';

        // App settings
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

        // Usage data

        // Load feature usage statistics

        _isLoading = false;
      });
      print('User data loaded successfully');
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _errorMessage = 'Failed to load user data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Update the in-memory values
      setState(() {
        _userName = _nameController.text;
        _userEmail = _emailController.text;
        _userPhone = _phoneController.text;
        _userLocation = _locationController.text;
      });

      // Save to SharedPreferences
      await prefs.setString('user_name', _nameController.text);
      await prefs.setString('user_email', _emailController.text);
      
      // Save based on user type
      if (_userType == 'farmer') {
        await prefs.setString('farmer_name', _nameController.text);
        await prefs.setString('farmer_email', _emailController.text);
        await prefs.setString('farmer_phone', _phoneController.text);
        await prefs.setString('farmer_location', _locationController.text);
      } else if (_userType == 'shopowner') {
        await prefs.setString('shop_name', _nameController.text);
        await prefs.setString('shop_email', _emailController.text);
        await prefs.setString('shop_phone', _phoneController.text);
        await prefs.setString('shop_location', _locationController.text);
      }

      print('User data saved successfully');
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile updated successfully',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.green[400],
          duration: const Duration(seconds: 2),
        ),
      );

    } catch (e) {
      print('Error saving user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving profile: $e',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _showEditProfileDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                _buildEditField('Location', _locationController, Icons.location_on),
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
              child: Text(
                'Save',
                style: GoogleFonts.poppins(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                _saveUserData();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, IconData icon) {
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: GoogleFonts.poppins(),
    );
  }

  Future<void> _saveNotificationPreference(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', enabled);
      print('Notification preference saved: $enabled');
    } catch (e) {
      print('Error saving notification preference: $e');
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
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
    ) ?? false;

    if (shouldLogout) {
      setState(() => _isLoggingOut = true);

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        // Show logout success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Logged out successfully',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: Colors.green[400],
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        print('Error during logout: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error during logout: $e',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
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
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_errorMessage.isNotEmpty) _buildErrorBanner(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
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
        color: Colors.green[400],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.maybePop(context),
              ),
              Expanded(
                child: Text(
                  "Settings",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.red),
            onPressed: () => setState(() => _errorMessage = ''),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Account Information',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.green[400], size: 20),
                  onPressed: _showEditProfileDialog,
                  tooltip: 'Edit Profile',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', _userName ?? 'Not set', Icons.person),
            const SizedBox(height: 12),
            _buildInfoRow('Email', _userEmail ?? 'Not set', Icons.email),
            const SizedBox(height: 12),
            _buildInfoRow('Phone', _userPhone ?? 'Not set', Icons.phone),
            const SizedBox(height: 12),
            _buildInfoRow('Location', _userLocation ?? 'Not set', Icons.location_on),
            const SizedBox(height: 12),
            _buildInfoRow('User Type', _getUserTypeDisplayName(), Icons.badge),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green[400], size: 20),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _buildSettingItem(
              icon: Icons.notifications,
              title: 'Notifications',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  _saveNotificationPreference(value);
                },
                activeColor: Colors.white,
                activeTrackColor: Colors.green[400],
                inactiveThumbColor: Colors.grey[300],
                inactiveTrackColor: Colors.grey[400],
              ),
            ),
            const Divider(height: 30),
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
                  const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                ],
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Language selection coming soon!',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
            const Divider(height: 30),
            _buildSettingItem(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Privacy policy coming soon!',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
            const Divider(height: 30),
            _buildSettingItem(
              icon: Icons.help,
              title: 'Help & Support',
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Help & support coming soon!',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
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
            Icon(icon, color: Colors.green[400], size: 24),
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        onPressed: _isLoggingOut ? null : _logout,
        child: _isLoggingOut
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
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