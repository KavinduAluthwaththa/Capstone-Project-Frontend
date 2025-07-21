import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/models/cropRecommendation_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CropSuggest extends StatefulWidget {
  const CropSuggest({super.key});

  @override
  _CropSuggestState createState() => _CropSuggestState();
}

class _CropSuggestState extends State<CropSuggest> {
  bool isLoading = true;
  bool isAnalyzing = false;
  String _errorMessage = '';
  
  // Weather data from SharedPreferences
  Map<String, dynamic> weatherData = {
    'temperature': 0.0,
    'humidity': 0,
    'rainfall': 0.0,
    'location': '',
  };
  
  // Manual weather input toggle
  bool useManualWeatherInput = false;
  
  // Controllers for text fields
  final nController = TextEditingController();
  final pController = TextEditingController();
  final kController = TextEditingController();
  final phController = TextEditingController();
  
  // Manual weather input controllers
  final temperatureController = TextEditingController();
  final humidityController = TextEditingController();
  final rainfallController = TextEditingController();
  
  // API response data
  Map<String, dynamic>? cropPredictionResponse;
  List<CropRecommendation> topRecommendations = [];
  
  // Session data
  String? _authToken;
  
  @override
  void initState() {
    super.initState();
    _loadSessionAndWeatherData();
  }
  
  @override
  void dispose() {
    nController.dispose();
    pController.dispose();
    kController.dispose();
    phController.dispose();
    temperatureController.dispose();
    humidityController.dispose();
    rainfallController.dispose();
    super.dispose();
  }
  
  // Load session data and weather data from SharedPreferences
  Future<void> _loadSessionAndWeatherData() async {
    setState(() {
      isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load session data
      _authToken = prefs.getString('auth_token');
      
      if (_authToken == null || _authToken!.isEmpty) {
        throw Exception('Authentication token missing. Please log in again.');
      }
      
      // Load weather data from SharedPreferences
      final temperature = prefs.getString('last_temperature') ?? '--°';
      final humidity = prefs.getString('last_humidity') ?? '--%';
      final location = prefs.getString('weather_location') ?? 'Unknown';
      
      // Parse temperature and humidity values
      double tempValue = 0.0;
      int humidityValue = 0;
      
      try {
        // Extract numeric value from temperature string (e.g., "28°" -> 28.0)
        final tempStr = temperature.replaceAll('°', '');
        if (tempStr != '--') {
          tempValue = double.parse(tempStr);
        }
        
        // Extract numeric value from humidity string (e.g., "65%" -> 65)
        final humidityStr = humidity.replaceAll('%', '');
        if (humidityStr != '--') {
          humidityValue = int.parse(humidityStr);
        }
      } catch (e) {
        print('Error parsing weather values: $e');
      }
      
      setState(() {
        weatherData = {
          'temperature': tempValue,
          'humidity': humidityValue,
          'rainfall': 0.0, // Will be estimated based on humidity
          'location': location,
        };
        
        // Estimate rainfall based on humidity (this is a rough estimation)
        if (humidityValue > 80) {
          weatherData['rainfall'] = 10.0;
        } else if (humidityValue > 60) {
          weatherData['rainfall'] = 5.0;
        } else {
          weatherData['rainfall'] = 1.0;
        }
        
        isLoading = false;
      });
      
      print('Weather data loaded from SharedPreferences:');
      print('Temperature: ${weatherData['temperature']}°C');
      print('Humidity: ${weatherData['humidity']}%');
      print('Estimated Rainfall: ${weatherData['rainfall']} mm');
      print('Location: ${weatherData['location']}');
      
    } catch (e) {
      print('Error loading weather data: $e');
      setState(() {
        _errorMessage = e.toString();
        isLoading = false;
      });
    }
  }
  
  // Method to get current weather data (automatic or manual)
  Map<String, dynamic> getCurrentWeatherData() {
    if (useManualWeatherInput) {
      // Use manual input values
      double temperature = double.tryParse(temperatureController.text) ?? 0.0;
      int humidity = int.tryParse(humidityController.text) ?? 0;
      double rainfall = double.tryParse(rainfallController.text) ?? 0.0;
      
      return {
        'temperature': temperature,
        'humidity': humidity,
        'rainfall': rainfall,
        'location': 'Manual Input',
      };
    } else {
      // Use automatic weather data from SharedPreferences
      return weatherData;
    }
  }
  
  // Method to validate manual weather input
  bool validateManualWeatherInput() {
    if (!useManualWeatherInput) return true;
    
    if (temperatureController.text.isEmpty || 
        humidityController.text.isEmpty || 
        rainfallController.text.isEmpty) {
      _showErrorSnackBar('Please fill in all weather parameters');
      return false;
    }
    
    double? temperature = double.tryParse(temperatureController.text);
    int? humidity = int.tryParse(humidityController.text);
    double? rainfall = double.tryParse(rainfallController.text);
    
    if (temperature == null || humidity == null || rainfall == null) {
      _showErrorSnackBar('Please enter valid numeric values for weather data');
      return false;
    }
    
    if (humidity < 0 || humidity > 100) {
      _showErrorSnackBar('Humidity must be between 0 and 100%');
      return false;
    }
    
    if (rainfall < 0) {
      _showErrorSnackBar('Rainfall cannot be negative');
      return false;
    }
    
    return true;
  }
  
  // Method to analyze soil data and get crop recommendations from API
  Future<void> analyzeSoilData() async {
    // Validate input fields
    if (nController.text.isEmpty || pController.text.isEmpty ||
        kController.text.isEmpty || phController.text.isEmpty) {
      _showErrorSnackBar('Please fill in all soil parameters');
      return;
    }
    
    // Validate manual weather input if enabled
    if (!validateManualWeatherInput()) {
      return;
    }
    
    // Parse the input values
    double? nitrogen = double.tryParse(nController.text);
    double? phosphorus = double.tryParse(pController.text);
    double? potassium = double.tryParse(kController.text);
    double? ph = double.tryParse(phController.text);
    
    if (nitrogen == null || phosphorus == null || potassium == null || ph == null) {
      _showErrorSnackBar('Please enter valid numeric values');
      return;
    }
    
    // Validate pH range
    if (ph < 0 || ph > 14) {
      _showErrorSnackBar('pH value must be between 0 and 14');
      return;
    }
    
    setState(() {
      isAnalyzing = true;
      _errorMessage = '';
    });
    
    try {
      // Get current weather data (automatic or manual)
      Map<String, dynamic> currentWeatherData = getCurrentWeatherData();
      
      // Prepare data in the required order: nitrogen, phosphorus, potassium, temperature, humidity, ph, rainfall
      final requestData = {
        "nitrogen": nitrogen,
        "phosphorus": phosphorus,
        "potassium": potassium,
        "temperature": currentWeatherData['temperature'],
        "humidity": currentWeatherData['humidity'],
        "ph": ph,
        "rainfall": currentWeatherData['rainfall'],
      };
      
      print('Sending crop prediction request:');
      print('API Endpoint: ${ApiEndpoints.cropPrediction}');
      print('Request Data: $requestData');
      print('Using manual weather input: $useManualWeatherInput');
      
      final response = await http.post(
        Uri.parse(ApiEndpoints.cropPrediction),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode(requestData),
      );
      
      print('Crop prediction response status: ${response.statusCode}');
      print('Crop prediction response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        setState(() {
          cropPredictionResponse = responseData;
          topRecommendations = _parseTopRecommendations(responseData);
          isAnalyzing = false;
        });
        
        _showSuccessSnackBar('Crop recommendation received successfully!');
        
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = 'Authentication failed. Please log in again.';
          isAnalyzing = false;
        });
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to get crop recommendation';
        throw Exception(errorMessage);
      }
      
    } catch (e) {
      print('Error getting crop recommendation: $e');
      setState(() {
        _errorMessage = 'Error: $e';
        isAnalyzing = false;
      });
      _showErrorSnackBar('Failed to get crop recommendation: $e');
    }
  }
  
  // Parse the API response to get top 3 recommendations
  List<CropRecommendation> _parseTopRecommendations(Map<String, dynamic> response) {
    List<CropRecommendation> recommendations = [];
    
    if (response.containsKey('probabilities')) {
      Map<String, dynamic> probabilities = response['probabilities'];
      
      // Convert probabilities to list and sort by confidence
      List<MapEntry<String, dynamic>> entries = probabilities.entries.toList();
      entries.sort((a, b) => (b.value as double).compareTo(a.value as double));
      
      // Take top 3 recommendations
      for (int i = 0; i < 3 && i < entries.length; i++) {
        recommendations.add(CropRecommendation(
          cropName: entries[i].key,
          confidence: (entries[i].value as double) * 100, // Convert to percentage
          rank: i + 1,
        ));
      }
    }
    
    return recommendations;
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            Expanded(
              child: isLoading
                  ? _buildLoadingState()
                  : _errorMessage.isNotEmpty
                      ? _buildErrorState()
                      : _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green[200]!.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                onPressed: () => Navigator.maybePop(context),
              ),
              Expanded(
                child: Text(
                  "Crop Recommendation",
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
            "AI-powered crop suggestions based on your soil and climate",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading weather data...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadSessionAndWeatherData,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(
                'Try Again',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400],
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
  
  Widget _buildMainContent() {
    return SingleChildScrollView(
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
          _buildAnalyzeButton(),
          const SizedBox(height: 25),
          
          // Top Recommendations section
          if (topRecommendations.isNotEmpty) ...[
            _buildRecommendationsSection(),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weather Data',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                if (!useManualWeatherInput)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.refresh, color: Colors.green[600]),
                      onPressed: _loadSessionAndWeatherData,
                      tooltip: 'Refresh weather data',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Toggle for manual weather input
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Use manual weather input',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Switch(
                    value: useManualWeatherInput,
                    onChanged: (value) {
                      setState(() {
                        useManualWeatherInput = value;
                        if (!value) {
                          // Clear manual input controllers when switching to automatic
                          temperatureController.clear();
                          humidityController.clear();
                          rainfallController.clear();
                        }
                      });
                    },
                    activeColor: Colors.green[600],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Display weather data or manual input fields
            if (useManualWeatherInput) ...[
              _buildManualWeatherInputs(),
            ] else ...[
              _buildAutomaticWeatherDisplay(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_pin, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Location: ${weatherData['location']}',
                        style: GoogleFonts.poppins(
                          fontStyle: FontStyle.italic,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildAutomaticWeatherDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildWeatherItem(
          Icons.thermostat,
          '${weatherData['temperature']}°C',
          'Temperature',
        ),
        _buildWeatherItem(
          Icons.water_drop,
          '${weatherData['humidity']}%',
          'Humidity',
        ),
        _buildWeatherItem(
          Icons.grain,
          '${weatherData['rainfall']} mm',
          'Rainfall (Est.)',
        ),
      ],
    );
  }
  
  Widget _buildWeatherItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 30, color: Colors.green[700]),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildManualWeatherInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Weather Data Manually',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildWeatherInputField(
                'Temperature',
                '°C',
                temperatureController,
                Icons.thermostat,
                'e.g., 28',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildWeatherInputField(
                'Humidity',
                '%',
                humidityController,
                Icons.water_drop,
                'e.g., 65',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildWeatherInputField(
          'Rainfall',
          'mm',
          rainfallController,
          Icons.grain,
          'e.g., 10.5',
        ),
      ],
    );
  }
  
  Widget _buildWeatherInputField(String label, String unit, TextEditingController controller, IconData icon, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: GoogleFonts.poppins(),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.blue[400], size: 20),
            suffixText: unit,
            suffixStyle: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[400]!),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            fillColor: Colors.grey[50],
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSoilInputSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Soil Parameters',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your soil test results for accurate recommendations',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'Nitrogen (N)',
                    'mg/kg',
                    nController,
                    Icons.science,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputField(
                    'Phosphorus (P)',
                    'mg/kg',
                    pController,
                    Icons.science,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'Potassium (K)',
                    'mg/kg',
                    kController,
                    Icons.science,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputField(
                    'pH Level',
                    '0-14',
                    phController,
                    Icons.science,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String unit, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: GoogleFonts.poppins(),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.green[400], size: 20),
            suffixText: unit,
            suffixStyle: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green[400]!),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            fillColor: Colors.grey[50],
            filled: true,
          ),
        ),
      ],
    );
  }
  
  Widget _buildAnalyzeButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAnalyzing 
              ? [Colors.grey[300]!, Colors.grey[400]!]
              : [Colors.green[400]!, Colors.green[600]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green[300]!.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isAnalyzing ? null : analyzeSoilData,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isAnalyzing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Analyzing...',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.psychology, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Get AI Crop Recommendations',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
  
  Widget _buildRecommendationsSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.green[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.agriculture, color: Colors.green[700], size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'Recommended Crops',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Display top 3 recommendations
            for (int i = 0; i < topRecommendations.length; i++) ...[
              _buildRecommendationCard(topRecommendations[i], i),
              if (i < topRecommendations.length - 1) const SizedBox(height: 12),
            ],
            
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'These recommendations are based on your soil conditions and local climate. Consider consulting with agricultural experts for best results.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecommendationCard(CropRecommendation recommendation, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Crop icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.green[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.eco,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Crop details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatCropName(recommendation.cropName),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Suitability: ${recommendation.confidence.toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Confidence indicator
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              color: Colors.green[600],
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatCropName(String cropName) {
    // Capitalize first letter and format crop names
    if (cropName.isEmpty) return cropName;
    
    // Handle special cases
    Map<String, String> specialNames = {
      'kidneybeans': 'Kidney Beans',
      'mothbeans': 'Moth Beans',
      'mungbean': 'Mung Bean',
      'muskmelon': 'Muskmelon',
      'pigeonpeas': 'Pigeon Peas',
      'blackgram': 'Black Gram',
    };
    
    if (specialNames.containsKey(cropName.toLowerCase())) {
      return specialNames[cropName.toLowerCase()]!;
    }
    
    // Default formatting: capitalize first letter
    return cropName[0].toUpperCase() + cropName.substring(1);
  }
}