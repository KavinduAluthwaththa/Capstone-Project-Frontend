import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/models/growingCrop_model.dart';
import 'package:capsfront/models/farmer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FarmerProfileScreen extends StatefulWidget {
  final Farmer farmer;

  const FarmerProfileScreen({super.key, required this.farmer});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  List<GrowingCrop> _farmerCrops = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isFavorite = false;
  List<String> _favoriteFarmers = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUserData();
    await _loadFavoriteFarmers();
    await _fetchFarmerCrops();
    await _saveUsageData();
  }

  Future<void> _loadUserData() async {
    try {
      // This method can be used to load user-specific data if needed
      // Currently just a placeholder for future user data loading
      print('Loading user data...');
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadFavoriteFarmers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _favoriteFarmers = prefs.getStringList('favorite_farmers') ?? [];
      setState(() {
        _isFavorite = _favoriteFarmers.contains(
          widget.farmer.farmerID.toString(),
        );
      });
    } catch (e) {
      print('Error loading favorite farmers: $e');
    }
  }

  Future<void> _saveFavoriteFarmers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorite_farmers', _favoriteFarmers);
    } catch (e) {
      print('Error saving favorite farmers: $e');
    }
  }

  Future<void> _saveUsageData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Update farmer profile usage count
      final currentCount = prefs.getInt('feature_usage_farmer_profile') ?? 0;
      await prefs.setInt('feature_usage_farmer_profile', currentCount + 1);

      // Save last used feature and activity time
      await prefs.setString('last_used_feature', 'farmer_profile');
      await prefs.setString(
        'last_activity_time',
        DateTime.now().toIso8601String(),
      );

      // Save recently viewed farmers
      List<String> recentFarmers = prefs.getStringList('recent_farmers') ?? [];
      String farmerId = widget.farmer.farmerID.toString();

      // Remove if already exists and add to front
      recentFarmers.remove(farmerId);
      recentFarmers.insert(0, farmerId);

      // Keep only last 10 recent farmers
      if (recentFarmers.length > 10) {
        recentFarmers = recentFarmers.sublist(0, 10);
      }

      await prefs.setStringList('recent_farmers', recentFarmers);

      // Save farmer interaction count
      final farmerInteractionKey =
          'farmer_interaction_${widget.farmer.farmerID}';
      final interactionCount = prefs.getInt(farmerInteractionKey) ?? 0;
      await prefs.setInt(farmerInteractionKey, interactionCount + 1);
    } catch (e) {
      print('Error saving usage data: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      setState(() {
        if (_isFavorite) {
          _favoriteFarmers.remove(widget.farmer.farmerID.toString());
          _isFavorite = false;
        } else {
          _favoriteFarmers.add(widget.farmer.farmerID.toString());
          _isFavorite = true;
        }
      });

      await _saveFavoriteFarmers();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Added to favorites' : 'Removed from favorites',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.green[400],
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  Future<void> _fetchFarmerCrops() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.get(
        Uri.parse(ApiEndpoints.getGrowingCropById(widget.farmer.farmerID)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          _farmerCrops =
              jsonData.map((json) => GrowingCrop.fromJson(json)).toList();
          _isLoading = false;
        });

        // Cache the data locally
        await _cacheFarmerCrops(jsonData);
      } else if (response.statusCode == 404) {
        setState(() {
          _farmerCrops = [];
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        throw Exception('Failed to load farmer crops: ${response.statusCode}');
      }
    } catch (e) {
      // Try to load cached data on error
      await _loadCachedFarmerCrops();
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _cacheFarmerCrops(List<dynamic> jsonData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'farmer_crops_${widget.farmer.farmerID}';
      await prefs.setString(cacheKey, json.encode(jsonData));
      await prefs.setString(
        '${cacheKey}_timestamp',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Error caching farmer crops: $e');
    }
  }

  Future<void> _loadCachedFarmerCrops() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'farmer_crops_${widget.farmer.farmerID}';
      final cachedData = prefs.getString(cacheKey);

      if (cachedData != null) {
        final List<dynamic> jsonData = json.decode(cachedData);
        setState(() {
          _farmerCrops =
              jsonData.map((json) => GrowingCrop.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Error loading cached farmer crops: $e');
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchFarmerCrops,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildFarmerInfoCard(),
                    const SizedBox(height: 16),
                    _buildStatsCard(),
                    const SizedBox(height: 16),
                    _buildFarmingCropsSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
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
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.maybePop(context),
              ),
              Expanded(
                child: Text(
                  widget.farmer.name,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.black,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Farmer Profile & Crop Information",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green[400],
                  radius: 30,
                  child: Text(
                    widget.farmer.name.isNotEmpty
                        ? widget.farmer.name[0].toUpperCase()
                        : 'F',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.farmer.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "FRM-${widget.farmer.farmerID}",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      if (_isFavorite)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Favorite',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow(Icons.location_on, widget.farmer.farmLocation),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, widget.farmer.phoneNumber.toString()),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.email, widget.farmer.Email),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.green[400], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Farmer Statistics',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Crops',
                    _farmerCrops.length.toString(),
                    Icons.agriculture,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Total Amount',
                    '${_farmerCrops.fold(0, (sum, crop) => sum + crop.amount)} kg',
                    Icons.inventory,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFarmingCropsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Farmed Crops & Quantities",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              _buildErrorWidget()
            else if (_farmerCrops.isEmpty && !_isLoading)
              _buildEmptyStateWidget()
            else
              ..._farmerCrops.map((crop) => _buildCropItem(crop)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error loading crops',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                Text(
                  _errorMessage!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.red),
            onPressed: _fetchFarmerCrops,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.agriculture_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No crops found',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'This farmer has not registered any crops yet',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchFarmerCrops,
              icon: const Icon(Icons.refresh),
              label: Text('Refresh', style: GoogleFonts.poppins()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropItem(GrowingCrop crop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  crop.crop.cropName,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Available",
                  style: GoogleFonts.poppins(
                    color: Colors.green[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCropDetail(
                  'Amount',
                  '${crop.amount} kg',
                  Icons.inventory,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCropDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green[400], size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
