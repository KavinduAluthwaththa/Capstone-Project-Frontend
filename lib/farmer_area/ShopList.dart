import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/farmer_area/ShopProfile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capsfront/models/shop_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShopListPage extends StatefulWidget {
  const ShopListPage({super.key});

  @override
  _ShopListPageState createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage> {
  List<Shop> _shops = [];
  bool _isLoading = true;
  String? _errorMessage;
  List<String> _favoriteShops = [];

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
    await _loadFavoriteShops();
    await _fetchShops();
    await _saveUsageData();
  }

  Future<void> _loadUserData() async {
    try {
      // User data loading logic can be added here if needed
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadFavoriteShops() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _favoriteShops = prefs.getStringList('favorite_shops') ?? [];
      });
    } catch (e) {
      print('Error loading favorite shops: $e');
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
      await prefs.setString(
        'last_activity_time',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Error saving usage data: $e');
    }
  }

  Future<void> _saveSelectedShop(Shop shop) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save recently viewed shops
      List<String> recentShops = prefs.getStringList('recent_shops') ?? [];
      String shopId = shop.shopID.toString();

      // Remove if already exists and add to front
      recentShops.remove(shopId);
      recentShops.insert(0, shopId);

      // Keep only last 10 recent shops
      if (recentShops.length > 10) {
        recentShops = recentShops.sublist(0, 10);
      }

      await prefs.setStringList('recent_shops', recentShops);

      // Save shop interaction count
      final shopInteractionKey = 'shop_interaction_${shop.shopID}';
      final interactionCount = prefs.getInt(shopInteractionKey) ?? 0;
      await prefs.setInt(shopInteractionKey, interactionCount + 1);

      // Save current shop data for the profile page
      await prefs.setString('current_shop_id', shop.shopID.toString());
      await prefs.setString('current_shop_name', shop.name);
      await prefs.setString('current_shop_location', shop.location);
      await prefs.setString('current_shop_phone', shop.phoneNumber);
      await prefs.setString('current_shop_email', shop.email);

      // Save shop selection timestamp
      await prefs.setString(
        'shop_selected_time',
        DateTime.now().toIso8601String(),
      );

      print('Shop data saved to SharedPreferences: ${shop.name}');
    } catch (e) {
      print('Error saving selected shop: $e');
    }
  }

  Future<void> _toggleFavorite(Shop shop) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> favorites = prefs.getStringList('favorite_shops') ?? [];

      setState(() {
        if (_favoriteShops.contains(shop.shopID.toString())) {
          _favoriteShops.remove(shop.shopID.toString());
          favorites.remove(shop.shopID.toString());
        } else {
          _favoriteShops.add(shop.shopID.toString());
          favorites.add(shop.shopID.toString());
        }
      });

      await prefs.setStringList('favorite_shops', favorites);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _favoriteShops.contains(shop.shopID.toString())
                ? 'Added to favorites'
                : 'Removed from favorites',
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

  Future<void> _fetchShops() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.get(
        Uri.parse(ApiEndpoints.getShops),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final shops = jsonData.map((json) => Shop.fromJson(json)).toList();

        setState(() {
          _shops = shops;
          _isLoading = false;
        });

        // Cache the data locally
        await _cacheShops(jsonData);
      } else {
        throw Exception('Failed to load shops: ${response.statusCode}');
      }
    } catch (e) {
      // Try to load cached data on error
      await _loadCachedShops();
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _cacheShops(List<dynamic> jsonData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_shops', json.encode(jsonData));
      await prefs.setString(
        'shops_cache_timestamp',
        DateTime.now().toIso8601String(),
      );

      // Save individual shop data for quick access
      for (var shopData in jsonData) {
        final shop = Shop.fromJson(shopData);
        final shopKey = 'shop_${shop.shopID}';
        await prefs.setString(shopKey, json.encode(shopData));
      }

      print('Cached ${jsonData.length} shops');
    } catch (e) {
      print('Error caching shops: $e');
    }
  }

  Future<void> _loadCachedShops() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_shops');

      if (cachedData != null) {
        final List<dynamic> jsonData = json.decode(cachedData);
        final shops = jsonData.map((json) => Shop.fromJson(json)).toList();
        setState(() {
          _shops = shops;
        });
        print('Loaded ${shops.length} shops from cache');
      }
    } catch (e) {
      print('Error loading cached shops: $e');
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
                onRefresh: _fetchShops,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [const SizedBox(height: 20), _buildShopsList()],
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
                  "Shop Directory",
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
            "Find shops to sell your crops",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShopsList() {
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

    if (_shops.isEmpty) {
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
                '${_shops.length} shops found',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        // Shop cards
        ..._shops.map((shop) => _buildShopCard(shop)),
      ],
    );
  }

  Widget _buildShopCard(Shop shop) {
    final isFavorite = _favoriteShops.contains(shop.shopID.toString());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () async {
          // Save shop data to SharedPreferences before navigation
          await _saveSelectedShop(shop);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShopProfilePage(shop: shop),
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
                      shop.name.isNotEmpty ? shop.name[0].toUpperCase() : 'S',
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
                          shop.name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
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
                    onPressed: () => _toggleFavorite(shop),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildShopDetailRow(Icons.phone, shop.phoneNumber),
              const SizedBox(height: 8),
              _buildShopDetailRow(Icons.location_on, shop.location),
              const SizedBox(height: 8),
              _buildShopDetailRow(Icons.email, shop.email),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopDetailRow(IconData icon, String text) {
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
                'Error loading shops',
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
                onPressed: _fetchShops,
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
              Icon(Icons.store_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No shops available',
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
                onPressed: _fetchShops,
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
