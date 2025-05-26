import 'package:flutter/material.dart';
import 'dart:async';
// You'll need to add http package to pubspec.yaml
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MaterialApp(
    home: CropSuggest(),
    debugShowCheckedModeBanner: false,
  ));
}

class CropSuggest extends StatefulWidget {
  const CropSuggest({super.key});

  @override
  _CropSuggestState createState() => _CropSuggestState();
}

class _CropSuggestState extends State<CropSuggest> {
  bool isLoading = true;
  bool isAnalyzing = false;
  
  // Weather data
  Map<String, dynamic> weatherData = {
    'temperature': 0.0,
    'humidity': 0,
    'rainfall': 0.0,
  };
  
  // Controllers for text fields
  final nController = TextEditingController();
  final pController = TextEditingController();
  final kController = TextEditingController();
  final phController = TextEditingController();
  
  // Sample data for crop suggestions (will be replaced by AI model output)
  final List<Map<String, dynamic>> cropSuggestions = [];
  
  @override
  void initState() {
    super.initState();
    // Fetch weather data when the widget initializes
    fetchWeatherData();
  }
  
  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    nController.dispose();
    pController.dispose();
    kController.dispose();
    phController.dispose();
    super.dispose();
  }
  
  // Method to fetch weather data from API
  Future<void> fetchWeatherData() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // Replace with your actual weather API call
      // This is a placeholder simulation
      await Future.delayed(const Duration(seconds: 2));
      
      // Sample weather data (replace with actual API response)
      setState(() {
        weatherData = {
          'temperature': 28.5,
          'humidity': 65,
          'rainfall': 2.3,
          'location': 'Sample Location',
        };
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch weather data. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Method to analyze soil data and get crop recommendations
  Future<void> analyzeSoilData() async {
    // Validate input fields
    if (nController.text.isEmpty || pController.text.isEmpty ||
        kController.text.isEmpty || phController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all soil parameters'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Parse the input values
    double? n = double.tryParse(nController.text);
    double? p = double.tryParse(pController.text);
    double? k = double.tryParse(kController.text);
    double? ph = double.tryParse(phController.text);
    
    if (n == null || p == null || k == null || ph == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid numeric values'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      isAnalyzing = true;
    });
    
    try {
      // Replace with your actual AI model API call
      // This is a placeholder simulation
      await Future.delayed(const Duration(seconds: 3));
      
      // Sample crop recommendations (replace with actual AI model response)
      setState(() {
        cropSuggestions.clear();
        cropSuggestions.addAll([
          {
            'name': 'Wheat',
            'suitability': 'High',
            'season': 'Winter',
            'waterRequirement': 'Moderate',
            'soilType': 'Loamy',
            'confidence': 92,
            'description': 'Ideal based on your soil parameters and current climate conditions.',
          },
          {
            'name': 'Corn',
            'suitability': 'Medium',
            'season': 'Summer',
            'waterRequirement': 'High',
            'soilType': 'Sandy loam',
            'confidence': 78,
            'description': 'Good option with adequate irrigation. Your N value is optimal for corn growth.',
          },
          {
            'name': 'Rice',
            'suitability': 'High',
            'season': 'Monsoon',
            'waterRequirement': 'Very High',
            'soilType': 'Clay',
            'confidence': 85,
            'description': 'Suitable for your soil pH and the current rainfall patterns.',
          },
        ]);
        isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        isAnalyzing = false;
      });
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to analyze data. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Crop Recommendation",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.green[400],
        centerTitle: true,
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: isLoading 
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.green),
                SizedBox(height: 20),
                Text('Fetching weather data...'),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weather information section
                _buildWeatherCard(),
                const SizedBox(height: 20),
                
                // Soil parameters input section
                _buildSoilInputSection(),
                const SizedBox(height: 25),
                
                // Analyze button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isAnalyzing ? null : analyzeSoilData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[500],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      disabledBackgroundColor: Colors.green[200],
                    ),
                    child: isAnalyzing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Analyzing...',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ],
                        )
                      : const Text(
                          'Get Crop Recommendations',
                          style: TextStyle(fontSize: 16),
                        ),
                  ),
                ),
                const SizedBox(height: 25),
                
                // Crop recommendations section
                if (cropSuggestions.isNotEmpty) ...[
                  const Text(
                    'Recommended Crops',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Based on your soil parameters and current weather conditions',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  
                  // List of crop suggestions
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cropSuggestions.length,
                    itemBuilder: (context, index) {
                      final crop = cropSuggestions[index];
                      return _buildCropCard(crop);
                    },
                  ),
                ],
              ],
            ),
          ),
    );
  }

  Widget _buildWeatherCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Weather',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.green),
                  onPressed: fetchWeatherData,
                  tooltip: 'Refresh weather data',
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherItem(
                  Icons.thermostat, 
                  '${weatherData['temperature']}°C', 
                  'Temperature'
                ),
                _buildWeatherItem(
                  Icons.water_drop, 
                  '${weatherData['humidity']}%', 
                  'Humidity'
                ),
                _buildWeatherItem(
                  Icons.grain, 
                  '${weatherData['rainfall']} mm', 
                  'Rainfall'
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Location: ${weatherData['location'] ?? 'Unknown'}',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.green[700]),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSoilInputSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Soil Parameters',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Enter your soil test results',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'Nitrogen (N)', 
                    'mg/kg', 
                    nController
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInputField(
                    'Phosphorus (P)', 
                    'mg/kg', 
                    pController
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'Potassium (K)', 
                    'mg/kg', 
                    kController
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInputField(
                    'pH Level', 
                    '', 
                    phController
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String unit, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            suffixText: unit,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildCropCard(Map<String, dynamic> crop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  crop['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildConfidenceChip(crop['confidence']),
              ],
            ),
            const SizedBox(height: 10),
            Text(crop['description']),
            const SizedBox(height: 15),
            _buildInfoRow('Season', crop['season']),
            _buildInfoRow('Water Requirement', crop['waterRequirement']),
            _buildInfoRow('Ideal Soil Type', crop['soilType']),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _showCropDetails(context, crop);
                },
                child: const Text('More Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceChip(int confidence) {
    Color chipColor;
    if (confidence >= 85) {
      chipColor = Colors.green;
    } else if (confidence >= 70) {
      chipColor = Colors.orange;
    } else {
      chipColor = Colors.red;
    }

    return Chip(
      label: Text(
        '$confidence% Confidence',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  Widget _buildSuitabilityChip(String suitability) {
    Color chipColor;
    switch (suitability.toLowerCase()) {
      case 'high':
        chipColor = Colors.green;
        break;
      case 'medium':
        chipColor = Colors.orange;
        break;
      case 'low':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.blue;
    }

    return Chip(
      label: Text(
        suitability,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showCropDetails(BuildContext context, Map<String, dynamic> crop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      crop['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildSuitabilityChip(crop['suitability']),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Detailed Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildDetailRow('Season', crop['season']),
                _buildDetailRow('Water Requirement', crop['waterRequirement']),
                _buildDetailRow('Ideal Soil Type', crop['soilType']),
                const SizedBox(height: 20),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${crop['description']} Additional details about growing ${crop['name']} would appear here, including optimal planting times, spacing requirements, fertilizer recommendations, and common issues to watch for during cultivation.',
                  style: const TextStyle(height: 1.5),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Add to user's crop list or other action
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${crop['name']} added to your crops'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[400],
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Add to My Crops',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}