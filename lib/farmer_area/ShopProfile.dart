import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/models/shop_model.dart';
import 'package:capsfront/models/request_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShopProfilePage extends StatefulWidget {
  final Shop shop;

  const ShopProfilePage({super.key, required this.shop});

  @override
  State<ShopProfilePage> createState() => _ShopProfilePageState();
}

class _ShopProfilePageState extends State<ShopProfilePage> {
  List<Request> _orderRequests = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isFavorite = false;
  List<String> _favoriteShops = [];
  String? _userType;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUserData();
    await _loadFavoriteShops();
    await _fetchOrderRequests();
    await _saveUsageData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userType = prefs.getString('user_type');
        _userName = prefs.getString('user_name') ?? 
                   prefs.getString('farmer_name') ?? 
                   prefs.getString('shop_name');
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadFavoriteShops() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _favoriteShops = prefs.getStringList('favorite_shops') ?? [];
      setState(() {
        _isFavorite = _favoriteShops.contains(widget.shop.shopID.toString());
      });
    } catch (e) {
      print('Error loading favorite shops: $e');
    }
  }

  Future<void> _saveFavoriteShops() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorite_shops', _favoriteShops);
    } catch (e) {
      print('Error saving favorite shops: $e');
    }
  }

  Future<void> _saveUsageData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Update shop list usage count
      final currentCount = prefs.getInt('feature_usage_shop_list') ?? 0;
      await prefs.setInt('feature_usage_shop_list', currentCount + 1);
      
      // Save last used feature and activity time
      await prefs.setString('last_used_feature', 'shop_list');
      await prefs.setString('last_activity_time', DateTime.now().toIso8601String());
      
      // Save recently viewed shops
      List<String> recentShops = prefs.getStringList('recent_shops') ?? [];
      String shopId = widget.shop.shopID.toString();
      
      // Remove if already exists and add to front
      recentShops.remove(shopId);
      recentShops.insert(0, shopId);
      
      // Keep only last 10 recent shops
      if (recentShops.length > 10) {
        recentShops = recentShops.sublist(0, 10);
      }
      
      await prefs.setStringList('recent_shops', recentShops);
      
      // Save shop interaction count
      final shopInteractionKey = 'shop_interaction_${widget.shop.shopID}';
      final interactionCount = prefs.getInt(shopInteractionKey) ?? 0;
      await prefs.setInt(shopInteractionKey, interactionCount + 1);
      
    } catch (e) {
      print('Error saving usage data: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      setState(() {
        if (_isFavorite) {
          _favoriteShops.remove(widget.shop.shopID.toString());
          _isFavorite = false;
        } else {
          _favoriteShops.add(widget.shop.shopID.toString());
          _isFavorite = true;
        }
      });
      
      await _saveFavoriteShops();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Added to favorites' : 'Removed from favorites',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.green[400],
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  Future<void> _fetchOrderRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.get(
        Uri.parse(ApiEndpoints.getRequestById(widget.shop.shopID)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          _orderRequests = jsonData.map((json) => Request.fromJson(json)).toList();
          _isLoading = false;
        });
        
        // Cache the data locally
        await _cacheOrderRequests(jsonData);
        
      } else if (response.statusCode == 404) {
        setState(() {
          _orderRequests = [];
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        throw Exception('Failed to load product requests: ${response.statusCode}');
      }
    } catch (e) {
      // Try to load cached data on error
      await _loadCachedOrderRequests();
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _cacheOrderRequests(List<dynamic> jsonData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'shop_requests_${widget.shop.shopID}';
      await prefs.setString(cacheKey, json.encode(jsonData));
      await prefs.setString('${cacheKey}_timestamp', DateTime.now().toIso8601String());
    } catch (e) {
      print('Error caching order requests: $e');
    }
  }

  Future<void> _loadCachedOrderRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'shop_requests_${widget.shop.shopID}';
      final cachedData = prefs.getString(cacheKey);
      
      if (cachedData != null) {
        final List<dynamic> jsonData = json.decode(cachedData);
        setState(() {
          _orderRequests = jsonData.map((json) => Request.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Error loading cached order requests: $e');
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
                onRefresh: _fetchOrderRequests,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildShopInfoCard(),
                      const SizedBox(height: 20),
                      _buildStatsCard(),
                      const SizedBox(height: 20),
                      _buildOrderRequestsSection(),
                    ],
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
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.maybePop(context),
              ),
              Expanded(
                child: Text(
                  widget.shop.name,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
            "Shop Profile & Product Requests",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShopInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
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
                    widget.shop.name.isNotEmpty ? widget.shop.name[0].toUpperCase() : 'S',
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
                        widget.shop.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "SHOP-${widget.shop.shopID}",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      if (_isFavorite)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
            _buildInfoRow(Icons.location_on, widget.shop.location),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, widget.shop.phoneNumber),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.email, widget.shop.email),
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
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
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
              'Shop Statistics',
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
                    'Total Requests',
                    _orderRequests.length.toString(),
                    Icons.shopping_cart,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Status',
                    _isFavorite ? 'Favorite' : 'Regular',
                    Icons.star,
                    _isFavorite ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
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
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderRequestsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Product Requests",
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
            else if (_orderRequests.isEmpty && !_isLoading)
              _buildEmptyStateWidget()
            else
              ..._orderRequests.map((request) => _buildOrderRequestItem(request)),
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
                  'Error loading requests',
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
            onPressed: _fetchOrderRequests,
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
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No product requests found',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchOrderRequests,
              icon: const Icon(Icons.refresh),
              label: Text(
                'Refresh',
                style: GoogleFonts.poppins(),
              ),
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

  Widget _buildOrderRequestItem(Request request) {
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
              Text(
                'Crop ID: ${request.cropID}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Pending",
                  style: GoogleFonts.poppins(
                    color: Colors.orange[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Request ID: ${request.requestID}",
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRequestDetail('Amount', '${request.amount} kg', Icons.scale),
              ),
              Expanded(
                child: _buildRequestDetail('Price', 'Rs. ${request.price}', Icons.monetization_on),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildRequestDetail('Date', request.date, Icons.calendar_today),
        ],
      ),
    );
  }

  Widget _buildRequestDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green[400], size: 16),
        const SizedBox(width: 8),
        Column(
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
      ],
    );
  }
}