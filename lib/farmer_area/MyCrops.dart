import 'dart:convert';
import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/farmer_area/AddGrowingCrop.dart';
import 'package:capsfront/models/growingCrop_model.dart';
import 'package:capsfront/accounts/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class CropsPage extends StatefulWidget {
  const CropsPage({super.key});

  @override
  State<CropsPage> createState() => _CropsPageState();
}

class _CropsPageState extends State<CropsPage> {
  List<GrowingCrop> growingCrops = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _farmerId;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _loadSessionAndFetchCrops();
  }

  Future<void> _loadSessionAndFetchCrops() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _authToken = prefs.getString('auth_token');
      _farmerId = prefs.getInt('farmer_id');
      
      print('Session data loaded - Farmer ID: $_farmerId, Token: ${_authToken?.isNotEmpty}');
      
      if (_authToken == null || _authToken!.isEmpty) {
        await _handleSessionExpired('Authentication token missing');
        return;
      }
      
      if (_farmerId == null) {
        setState(() {
          _errorMessage = 'Farmer ID not found. Please log in again.';
          _isLoading = false;
        });
        return;
      }
      
      await _fetchGrowingCrops();
    } catch (e) {
      print('Error loading session: $e');
      setState(() {
        _errorMessage = 'Session error: $e';
        _isLoading = false;
      });
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
            title: const Text('Session Expired'),
            content: Text('Your session has expired. Please log in again.\n\nReason: $reason'),
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
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _fetchGrowingCrops() async {
    if (_farmerId == null || _authToken == null) {
      setState(() {
        _errorMessage = 'Missing farmer ID or authentication token';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Fetching crops for farmer ID: $_farmerId');
      
      final response = await http.get(
        Uri.parse(ApiEndpoints.getGrowingCropById(_farmerId!)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      print('API response status: ${response.statusCode}');
      print('API response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse is Map<String, dynamic>) {
          final GrowingCrop crop = GrowingCrop.fromJson(jsonResponse);
          setState(() {
            growingCrops = [crop];
            _errorMessage = null;
          });
        } else if (jsonResponse is List) {
          final List<GrowingCrop> loadedCrops = jsonResponse
              .map((e) => GrowingCrop.fromJson(e as Map<String, dynamic>))
              .toList();
          setState(() {
            growingCrops = loadedCrops;
            _errorMessage = null;
          });
        } else {
          setState(() {
            growingCrops = [];
            _errorMessage = null;
          });
        }
      } else if (response.statusCode == 401) {
        await _handleSessionExpired('Authentication failed');
        return;
      } else if (response.statusCode == 404) {
        setState(() {
          growingCrops = [];
          _errorMessage = null;
        });
      } else {
        throw Exception('Failed to load crops: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching crops: $e');
      setState(() {
        growingCrops = [];
        _errorMessage = 'Error loading crops: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteGrowingCrop(int cfid) async {
    if (_authToken == null) {
      _showErrorSnackBar('Authentication token missing');
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse(ApiEndpoints.deleteGrowingCrop(cfid.toString())),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Crop record deleted successfully');
        await _fetchGrowingCrops();
      } else if (response.statusCode == 401) {
        await _handleSessionExpired('Authentication failed');
      } else {
        throw Exception('Failed to delete crop: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('Error deleting crop: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_errorMessage != null) _buildErrorBanner(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    )
                  : growingCrops.isEmpty
                      ? _buildEmptyState()
                      : _buildCropsList(),
            ),
            _buildAddButton(),
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
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Text(
                  "My Crop Records",
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
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.red),
            onPressed: () => setState(() => _errorMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildCropsList() {
    return RefreshIndicator(
      onRefresh: _fetchGrowingCrops,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: growingCrops.length,
          itemBuilder: (context, index) => _buildCropCard(growingCrops[index]),
        ),
      ),
    );
  }

  Widget _buildCropCard(GrowingCrop crop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.green[400],
                  child: Text(
                    crop.crop.cropName[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop.crop.cropName,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Amount: ${crop.amount} kg',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(crop.cfid),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.calendar_today, 'Planted', _formatDate(crop.date)),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.location_on, 'Location', crop.farmer.farmLocation),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.person, 'Farmer', crop.farmer.name),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.green[700]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.grass,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No crop records found',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start by adding your first crop record',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchGrowingCrops,
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _farmerId != null ? _navigateToAddCrop : null,
          icon: const Icon(Icons.add_circle_outline, size: 24),
          label: Text(
            'Add New Crop Record',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[400],
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToAddCrop() async {
    if (_farmerId == null) {
      _showErrorSnackBar('Farmer ID not available');
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddGrowingCropScreen(farmerId: _farmerId!),
      ),
    );
    
    if (result == true) {
      await _fetchGrowingCrops();
    }
  }

  void _showDeleteConfirmation(int cfid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'Confirm Delete',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this crop record? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteGrowingCrop(cfid);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}