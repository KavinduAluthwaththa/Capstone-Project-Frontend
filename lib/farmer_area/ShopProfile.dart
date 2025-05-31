import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/models/shop_model.dart';
import 'package:capsfront/models/request_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Color Palette - Reusing from the previous style
const Color appBackgroundColor = Colors.white;
const Color topBarColor = Color(0xFFAED581);
const Color mainCardBackgroundColor = Color(0xFFDCEBCB);
const Color orderItemBackgroundColor = Color(0xFFEFF3ED);
const Color bottomNavBarColor = Color(0xFF5B8C5A);
const Color primaryTextColor = Colors.black;
const Color secondaryTextColor = Colors.black54;
const Color tertiaryTextColor = Colors.black38;
const Color bottomNavIconSelectedColor = Colors.white;
const Color bottomNavIconUnselectedColor = Color(0xFF3D533D);
const Color pendingStatusColor = Color(0xFFFFEEA2);

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

  @override
  void initState() {
    super.initState();
    _fetchOrderRequests();
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
    } else if (response.statusCode == 404) {
      // Handle 404 - No requests found
      setState(() {
        _orderRequests = [];
        _isLoading = false;
        _errorMessage = null; // Clear error message for 404
      });
    } else {
      throw Exception('Failed to load product requests: ${response.statusCode}');
    }
  } catch (e) {
    setState(() {
      _errorMessage = e.toString();
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          widget.shop.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: primaryTextColor,
          ),
        ),
        backgroundColor: Colors.green[400],
        centerTitle: true,
        toolbarHeight: 100,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        iconTheme: const IconThemeData(color: primaryTextColor),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrderRequests,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
          child: Column(
            children: [
              _buildShopInfoCard(),
              const SizedBox(height: 20),
              _buildOrderRequestsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: mainCardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green[400],
                radius: 25,
                child: Text(
                  widget.shop.shopID.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.shop.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "SHOP-${widget.shop.shopID}",
                      style: const TextStyle(color: secondaryTextColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildInfoRow(Icons.location_on_outlined, widget.shop.location),
          _buildInfoRow(Icons.phone_outlined, widget.shop.phoneNumber),
          _buildInfoRow(Icons.email_outlined, widget.shop.email),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: primaryTextColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: primaryTextColor, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderRequestsSection() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: mainCardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Product Request",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 15),
          if (_errorMessage != null)
            _buildErrorWidget()
          else if (_orderRequests.isEmpty && !_isLoading)
            _buildEmptyStateWidget()
          else
            ..._orderRequests.map((request) => _buildOrderRequestItem(request)),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(10),
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
                const Text(
                  'Error loading requests',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _errorMessage!,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
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
            const Text(
              'No product requests found',
              style: TextStyle(
                fontSize: 16,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _fetchOrderRequests,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderRequestItem(Request request) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: orderItemBackgroundColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Crop ID: ${request.cropID}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: primaryTextColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: pendingStatusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Pending",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Request ID: ${request.requestID}",
              style: const TextStyle(color: secondaryTextColor, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  "Amount: ",
                  style: TextStyle(color: tertiaryTextColor, fontSize: 14),
                ),
                Text(
                  "${request.amount} kg",
                  style: const TextStyle(
                    color: primaryTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text(
                  "Price: ",
                  style: TextStyle(color: tertiaryTextColor, fontSize: 14),
                ),
                Text(
                  "Rs. ${request.price}",
                  style: const TextStyle(
                    color: primaryTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text(
                  "Date: ",
                  style: TextStyle(color: tertiaryTextColor, fontSize: 14),
                ),
                Text(
                  request.date,
                  style: const TextStyle(
                    color: primaryTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}