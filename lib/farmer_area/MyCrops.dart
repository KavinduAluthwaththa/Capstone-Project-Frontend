import 'dart:convert';
import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/farmer_area/AddGrowingCrop.dart';
import 'package:capsfront/models/growingCrop_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CropsPage extends StatefulWidget {
  final int farmerId;
  const CropsPage({super.key, required this.farmerId});

  @override
  State<CropsPage> createState() => _CropsPageState();
}

class _CropsPageState extends State<CropsPage> {
  List<GrowingCrop> growingCrops = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchGrowingCrops();
  }
  
  Future<void> _fetchGrowingCrops() async {
  setState(() => _isLoading = true);

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final response = await http.get(
      Uri.parse(ApiEndpoints.getGrowingCropById(widget.farmerId)),
      headers: {'Authorization': 'Bearer $token'},
    );

    debugPrint('Response body: ${response.body}');

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
      }
    } else {
      throw Exception('Failed to load crops: ${response.statusCode}');
    }
  } catch (e) {
    setState(() {
      growingCrops = [];
    });
  } finally {
    setState(() => _isLoading = false);
  }
}

  Future<void> _deleteGrowingCrop(int cfid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.delete(
        Uri.parse(ApiEndpoints.deleteGrowingCrop(cfid.toString())),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Crop record deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        await _fetchGrowingCrops();
      } else {
        throw Exception('Failed to delete crop: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "My Crop Records",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700],
        centerTitle: true,
        toolbarHeight: 70,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        elevation: 4,
      ),
      body: Column(
        children: [
          if (_errorMessage != null) _buildErrorBanner(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : growingCrops.isEmpty
                    ? _buildEmptyState()
                    : _buildCropGrid(),
          ),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.red[50],
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() => _errorMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildCropGrid() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: growingCrops.length,
        itemBuilder: (context, index) => _buildCropCard(growingCrops[index]),
      ),
    );
  }

  Widget _buildCropCard(GrowingCrop crop) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {}, // Add onTap functionality if needed
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      crop.crop.cropName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => _showDeleteConfirmation(crop.cfid),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildCropDetail(Icons.scale, 'Amount: ${crop.amount} kg'),
              _buildCropDetail(Icons.calendar_today, 'Planted: ${_formatDate(crop.date)}'),
              _buildCropDetail(Icons.location_on, 'Location: ${crop.farmer.farmLocation}'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[100]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.grass, size: 16, color: Colors.green[800]),
                    const SizedBox(width: 6),
                    Text(
                      crop.crop.plantingSeason,
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCropDetail(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grass, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No crop records found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _fetchGrowingCrops,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[50],
              foregroundColor: Colors.green[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: ElevatedButton.icon(
        onPressed: _navigateToAddCrop,
        icon: const Icon(Icons.add_circle_outline, size: 22),
        label: const Text(
          'Add New Crop Record',
          style: TextStyle(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToAddCrop() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddGrowingCropScreen(farmerId: widget.farmerId),
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
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this crop record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteGrowingCrop(cfid);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}