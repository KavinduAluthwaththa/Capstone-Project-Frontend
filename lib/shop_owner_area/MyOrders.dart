import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/models/request_model.dart';
import 'package:capsfront/shop_owner_area/AddOrders.dart';
import 'package:capsfront/accounts/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyRequestsPage extends StatefulWidget {
  const MyRequestsPage({super.key, required this.shopID});

  final int shopID;

  @override
  State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  List<Request> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _loadSessionAndFetchRequests();
  }

  Future<void> _loadSessionAndFetchRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _authToken = prefs.getString('auth_token');
      
      print('Session data loaded - Shop ID: ${widget.shopID}, Token: ${_authToken?.isNotEmpty}');
      
      if (_authToken == null || _authToken!.isEmpty) {
        await _handleSessionExpired('Authentication token missing');
        return;
      }
      
      await _fetchRequests();
      await _saveUsageData();
    } catch (e) {
      print('Error loading session: $e');
      setState(() {
        _errorMessage = 'Session error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUsageData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Update my orders usage count
      final currentCount = prefs.getInt('feature_usage_my_orders') ?? 0;
      await prefs.setInt('feature_usage_my_orders', currentCount + 1);
      
      // Save last used feature and activity time
      await prefs.setString('last_used_feature', 'my_orders');
      await prefs.setString('last_activity_time', DateTime.now().toIso8601String());
      
    } catch (e) {
      print('Error saving usage data: $e');
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

  Future<void> _fetchRequests() async {
    if (_authToken == null) {
      setState(() {
        _errorMessage = 'Missing authentication token';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Fetching requests for shop ID: ${widget.shopID}');
      
      final response = await http.get(
        Uri.parse(ApiEndpoints.getRequestByShopId(widget.shopID)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      print('API response status: ${response.statusCode}');
      print('API response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Request> loadedRequests = data
            .map((e) => Request.fromJson(e as Map<String, dynamic>))
            .toList();
        
        setState(() {
          _requests = loadedRequests;
          _errorMessage = null;
        });

        // Cache the requests
        await _cacheRequests(data);
        
      } else if (response.statusCode == 401) {
        await _handleSessionExpired('Authentication failed');
        return;
      } else if (response.statusCode == 404) {
        setState(() {
          _requests = [];
          _errorMessage = null;
        });
      } else {
        throw Exception('Failed to load requests: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching requests: $e');
      // Try to load cached data on error
      await _loadCachedRequests();
      setState(() {
        _errorMessage = 'Error loading requests: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cacheRequests(List<dynamic> requestsData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_requests_${widget.shopID}', json.encode(requestsData));
      await prefs.setString('requests_cache_timestamp', DateTime.now().toIso8601String());
      print('Cached ${requestsData.length} requests');
    } catch (e) {
      print('Error caching requests: $e');
    }
  }

  Future<void> _loadCachedRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_requests_${widget.shopID}');
      
      if (cachedData != null) {
        final List<dynamic> jsonData = json.decode(cachedData);
        final requests = jsonData.map((json) => Request.fromJson(json)).toList();
        setState(() {
          _requests = requests;
        });
        print('Loaded ${requests.length} requests from cache');
      }
    } catch (e) {
      print('Error loading cached requests: $e');
    }
  }

  Future<void> _navigateToAddOrder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddOrderPage(shopId: widget.shopID),
      ),
    );
    if (result == true) {
      await _fetchRequests();
    }
  }

  Future<void> _deleteRequest(int requestId) async {
    if (_authToken == null) {
      _showErrorSnackBar('Authentication token missing');
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse(ApiEndpoints.deleteRequest(requestId.toString())),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Request deleted successfully');
        await _fetchRequests();
      } else if (response.statusCode == 401) {
        await _handleSessionExpired('Authentication failed');
      } else {
        throw Exception('Failed to delete request: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('Error deleting request: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.green[400],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.red[400],
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
                  : _requests.isEmpty
                      ? _buildEmptyState()
                      : _buildRequestsList(),
            ),
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _navigateToAddOrder,
          icon: const Icon(Icons.add_circle_outline, size: 24),
          label: Text(
            'Add New Order Request',
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
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Text(
                  "My Order Requests",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
              _errorMessage!,
              style: GoogleFonts.poppins(
                color: Colors.red[700],
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: Colors.red[600]),
            onPressed: () => setState(() => _errorMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    return RefreshIndicator(
      onRefresh: _fetchRequests,
      color: Colors.green[400],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: _requests.length,
          itemBuilder: (context, index) => _buildRequestCard(_requests[index]),
        ),
      ),
    );
  }

  Widget _buildRequestCard(Request request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green[400]!, Colors.green[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          request.cropID.toString(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Crop ID: ${request.cropID}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Request ID: ${request.requestID}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red[600], size: 20),
                        onPressed: () => _showDeleteConfirmation(request.requestID),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[50]!, Colors.green[100]!.withOpacity(0.3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!, width: 1),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.scale, 'Amount', '${request.amount} kg'),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.attach_money, 'Price', '₱${request.price.toString()}'),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.calendar_today, 'Date', _formatDate(request.date)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.green[200],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: Colors.green[800]),
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[300]!, Colors.grey[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No order requests found',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start by creating your first order request to connect with farmers',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _fetchRequests,
              icon: const Icon(Icons.refresh, size: 20),
              label: Text(
                'Refresh',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int requestId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.delete_outline, color: Colors.red[600], size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Confirm Delete',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this order request? This action cannot be undone.',
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red[400]!, Colors.red[600]!],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteRequest(requestId);
              },
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
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