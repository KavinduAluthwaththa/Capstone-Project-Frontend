import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/shop_owner_area/FarmerProfile.dart' as profile;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capsfront/models/farmer_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FarmersListPage extends StatefulWidget {
  const FarmersListPage({super.key});

  @override
  _FarmersListPageState createState() => _FarmersListPageState();
}

class _FarmersListPageState extends State<FarmersListPage> {
  List<Farmer> _farmers = [];
  bool _isLoading = true;
  String? _errorMessage;
  List<String> _favoriteFarmers = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadUserData();
    await _loadFavoriteFarmers();
    await _fetchFarmers();
    await _saveUsageData();
  }

  Future<void> _loadUserData() async {
    try {
      // User data loading logic can be added here if needed
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadFavoriteFarmers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _favoriteFarmers = prefs.getStringList('favorite_farmers') ?? [];
      });
    } catch (e) {
      print('Error loading favorite farmers: $e');
    }
  }

  Future<void> _saveUsageData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Update farmers list usage count
      final currentCount = prefs.getInt('feature_usage_farmers_list') ?? 0;
      await prefs.setInt('feature_usage_farmers_list', currentCount + 1);

      // Save last used feature and activity time
      await prefs.setString('last_used_feature', 'farmers_list');
      await prefs.setString(
        'last_activity_time',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Error saving usage data: $e');
    }
  }

  Future<void> _saveSelectedFarmer(Farmer farmer) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save recently viewed farmers
      List<String> recentFarmers = prefs.getStringList('recent_farmers') ?? [];
      String farmerId = farmer.farmerID.toString();

      // Remove if already exists and add to front
      recentFarmers.remove(farmerId);
      recentFarmers.insert(0, farmerId);

      // Keep only last 10 recent farmers
      if (recentFarmers.length > 10) {
        recentFarmers = recentFarmers.sublist(0, 10);
      }

      await prefs.setStringList('recent_farmers', recentFarmers);

      // Save farmer interaction count
      final farmerInteractionKey = 'farmer_interaction_${farmer.farmerID}';
      final interactionCount = prefs.getInt(farmerInteractionKey) ?? 0;
      await prefs.setInt(farmerInteractionKey, interactionCount + 1);

      // Save current farmer data for the profile page
      await prefs.setString('current_farmer_id', farmer.farmerID.toString());
      await prefs.setString('current_farmer_name', farmer.name);
      await prefs.setString('current_farmer_location', farmer.farmLocation);
      await prefs.setString(
        'current_farmer_phone',
        farmer.phoneNumber.toString(),
      );
      await prefs.setString('current_farmer_email', farmer.Email);

      // Save farmer selection timestamp
      await prefs.setString(
        'farmer_selected_time',
        DateTime.now().toIso8601String(),
      );

      print('Farmer data saved to SharedPreferences: ${farmer.name}');
    } catch (e) {
      print('Error saving selected farmer: $e');
    }
  }

  Future<void> _toggleFavorite(Farmer farmer) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> favorites = prefs.getStringList('favorite_farmers') ?? [];

      setState(() {
        if (_favoriteFarmers.contains(farmer.farmerID.toString())) {
          _favoriteFarmers.remove(farmer.farmerID.toString());
          favorites.remove(farmer.farmerID.toString());
        } else {
          _favoriteFarmers.add(farmer.farmerID.toString());
          favorites.add(farmer.farmerID.toString());
        }
      });

      await prefs.setStringList('favorite_farmers', favorites);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _favoriteFarmers.contains(farmer.farmerID.toString())
                ? 'Added to favorites'
                : 'Removed from favorites',
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

  Future<void> _fetchFarmers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.get(
        Uri.parse(ApiEndpoints.getFarmers),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final farmers = jsonData.map((json) => Farmer.fromJson(json)).toList();

        setState(() {
          _farmers = farmers;
          _isLoading = false;
        });

        // Cache the data locally
        await _cacheFarmers(jsonData);
      } else {
        throw Exception('Failed to load farmers: ${response.statusCode}');
      }
    } catch (e) {
      // Try to load cached data on error
      await _loadCachedFarmers();
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _cacheFarmers(List<dynamic> jsonData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_farmers', json.encode(jsonData));
      await prefs.setString(
        'farmers_cache_timestamp',
        DateTime.now().toIso8601String(),
      );

      // Save individual farmer data for quick access
      for (var farmerData in jsonData) {
        final farmer = Farmer.fromJson(farmerData);
        final farmerKey = 'farmer_${farmer.farmerID}';
        await prefs.setString(farmerKey, json.encode(farmerData));
      }

      print('Cached ${jsonData.length} farmers');
    } catch (e) {
      print('Error caching farmers: $e');
    }
  }

  Future<void> _loadCachedFarmers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_farmers');

      if (cachedData != null) {
        final List<dynamic> jsonData = json.decode(cachedData);
        final farmers = jsonData.map((json) => Farmer.fromJson(json)).toList();
        setState(() {
          _farmers = farmers;
        });
        print('Loaded ${farmers.length} farmers from cache');
      }
    } catch (e) {
      print('Error loading cached farmers: $e');
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
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchFarmers,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [const SizedBox(height: 20), _buildFarmersList()],
                  ),
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
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.maybePop(context),
              ),
              Expanded(
                child: Text(
                  "Farmers Directory",
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
            "Connect with farmers in your area",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFarmersList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (_farmers.isEmpty) {
      return _buildEmptyStateWidget();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results header
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_farmers.length} farmers found',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        // Farmer cards
        ..._farmers.map((farmer) => _buildFarmerCard(farmer)),
      ],
    );
  }

  Widget _buildFarmerCard(Farmer farmer) {
    final isFavorite = _favoriteFarmers.contains(farmer.farmerID.toString());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () async {
          // Save farmer data to SharedPreferences before navigation
          await _saveSelectedFarmer(farmer);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => profile.FarmerProfileScreen(farmer: farmer),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green[400],
                    radius: 25,
                    child: Text(
                      farmer.name.isNotEmpty
                          ? farmer.name[0].toUpperCase()
                          : 'F',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farmer.name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "ID: FRM-${farmer.farmerID}",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey[400],
                    ),
                    onPressed: () => _toggleFavorite(farmer),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFarmerDetailRow(Icons.phone, farmer.phoneNumber.toString()),
              const SizedBox(height: 8),
              _buildFarmerDetailRow(Icons.location_on, farmer.farmLocation),
              const SizedBox(height: 8),
              _buildFarmerDetailRow(Icons.email, farmer.Email),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFarmerDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.green[400], size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                'Error loading farmers',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.red[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchFarmers,
                icon: const Icon(Icons.refresh),
                label: Text('Retry', style: GoogleFonts.poppins()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.agriculture_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No farmers available',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pull down to refresh the list',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchFarmers,
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
      ),
    );
  }
}
