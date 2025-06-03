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
  List<Shop> _filteredShops = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  List<String> _favoriteShops = [];
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
      final prefs = await SharedPreferences.getInstance();
      setState(() {
      });
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
      await prefs.setString('last_activity_time', DateTime.now().toIso8601String());
      
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
      await prefs.setString('shop_selected_time', DateTime.now().toIso8601String());
      
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
          _filteredShops = shops;
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
      await prefs.setString('shops_cache_timestamp', DateTime.now().toIso8601String());
      
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
          _filteredShops = shops;
        });
        print('Loaded ${shops.length} shops from cache');
      }
    } catch (e) {
      print('Error loading cached shops: $e');
    }
  }

  void _filterShops(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredShops = _shops;
      } else {
        _filteredShops = _shops.where((shop) {
          return shop.name.toLowerCase().contains(query.toLowerCase()) ||
                 shop.location.toLowerCase().contains(query.toLowerCase()) ||
                 shop.phoneNumber.contains(query);
        }).toList();
      }
    });
  }

  void _sortShops(String sortBy) {
    setState(() {
      switch (sortBy) {
        case 'name':
          _filteredShops.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'location':
          _filteredShops.sort((a, b) => a.location.compareTo(b.location));
          break;
        case 'favorites':
          _filteredShops.sort((a, b) {
            bool aIsFavorite = _favoriteShops.contains(a.shopID.toString());
            bool bIsFavorite = _favoriteShops.contains(b.shopID.toString());
            if (aIsFavorite && !bIsFavorite) return -1;
            if (!aIsFavorite && bIsFavorite) return 1;
            return a.name.compareTo(b.name);
          });
          break;
      }
    });
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
                    children: [
                      const SizedBox(height: 20),
                      _buildSearchAndFilter(),
                      const SizedBox(height: 20),
                      _buildShopsList(),
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
                  "Shop Directory",
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
          const SizedBox(height: 8),
          Text(
            "Find agricultural shops near you",
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

  Widget _buildSearchAndFilter() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: _filterShops,
              decoration: InputDecoration(
                hintText: "Search shops by name, location, or phone",
                hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: Colors.green[400]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterShops('');
                        },
                      )
                    : null,
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
            ),
            const SizedBox(height: 16),
            
            // Filter and Sort Row
            Row(
              children: [
                Expanded(
                  child: _buildFilterChip('All Shops', Icons.store, () {
                    setState(() {
                      _filteredShops = _shops;
                    });
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip('Favorites', Icons.favorite, () {
                    setState(() {
                      _filteredShops = _shops.where((shop) => 
                        _favoriteShops.contains(shop.shopID.toString())
                      ).toList();
                    });
                  }),
                ),
                const SizedBox(width: 8),
                _buildSortButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.green[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.green[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      onSelected: _sortShops,
      icon: Icon(Icons.sort, color: Colors.green[400]),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'name',
          child: Row(
            children: [
              const Icon(Icons.sort_by_alpha, size: 16),
              const SizedBox(width: 8),
              Text('Name', style: GoogleFonts.poppins()),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'location',
          child: Row(
            children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 8),
              Text('Location', style: GoogleFonts.poppins()),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'favorites',
          child: Row(
            children: [
              const Icon(Icons.favorite, size: 16),
              const SizedBox(width: 8),
              Text('Favorites First', style: GoogleFonts.poppins()),
            ],
          ),
        ),
      ],
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

    if (_filteredShops.isEmpty) {
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
                '${_filteredShops.length} shops found',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (_searchQuery.isNotEmpty)
                Text(
                  'for "$_searchQuery"',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
        
        // Shop cards
        ..._filteredShops.map((shop) => _buildShopCard(shop)),
      ],
    );
  }

  Widget _buildShopCard(Shop shop) {
    final isFavorite = _favoriteShops.contains(shop.shopID.toString());
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
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
                        const SizedBox(height: 4),
                        Text(
                          "ID: SHOP-${shop.shopID}",
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
                    onPressed: () => _toggleFavorite(shop),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
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
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
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
                label: Text(
                  'Retry',
                  style: GoogleFonts.poppins(),
                ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.store_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty ? 'No shops found' : 'No shops available',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty 
                    ? 'Try searching with different keywords'
                    : 'Pull down to refresh the list',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _searchQuery.isNotEmpty 
                    ? () {
                        _searchController.clear();
                        _filterShops('');
                      }
                    : _fetchShops,
                icon: Icon(_searchQuery.isNotEmpty ? Icons.clear : Icons.refresh),
                label: Text(
                  _searchQuery.isNotEmpty ? 'Clear Search' : 'Refresh',
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
      ),
    );
  }
}