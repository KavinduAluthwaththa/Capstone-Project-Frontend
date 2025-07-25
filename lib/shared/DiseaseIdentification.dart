import 'dart:io';
import 'dart:convert';
import 'package:capsfront/models/DiseaseResult_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capsfront/constraints/api_endpoint.dart';

class DiseaseM extends StatefulWidget {
  const DiseaseM({super.key});

  @override
  _DiseaseMState createState() => _DiseaseMState();
}

class _DiseaseMState extends State<DiseaseM> {
  File? _image;
  Uint8List? _webImage;
  bool _isAnalyzing = false;
  List<DiseaseResult> _diseaseResults = [];
  String? _authToken;
  String _selectedCrop = 'potato'; // Default selection
  final TextEditingController _commentsController = TextEditingController();

  final List<Map<String, String>> _cropTypes = [
    {'name': 'Potato', 'value': 'potato', 'icon': '🥔'},
    {'name': 'Rice', 'value': 'rice', 'icon': '🌾'},
    {'name': 'Pumpkin', 'value': 'pumpkin', 'icon': '🎃'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _authToken = prefs.getString('auth_token');
    });
  }

  String _getApiEndpoint() {
    switch (_selectedCrop) {
      case 'potato':
        return ApiEndpoints.potatodisease;
      case 'rice':
        return ApiEndpoints.ricedisease;
      case 'pumpkin':
        return ApiEndpoints.pumpkindisease;
      default:
        return ApiEndpoints.potatodisease;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        // For web, read as bytes
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _image = null;
          _diseaseResults.clear(); // Clear previous results
        });
      } else {
        // For mobile/desktop, use file
        setState(() {
          _image = File(pickedFile.path);
          _webImage = null;
          _diseaseResults.clear(); // Clear previous results
        });
      }
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        // For web, read as bytes
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _image = null;
          _diseaseResults.clear(); // Clear previous results
        });
      } else {
        // For mobile/desktop, use file
        setState(() {
          _image = File(pickedFile.path);
          _webImage = null;
          _diseaseResults.clear(); // Clear previous results
        });
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null && _webImage == null) {
      _showErrorSnackBar('Please select an image first');
      return;
    }

    if (_authToken == null || _authToken!.isEmpty) {
      _showErrorSnackBar('Authentication required. Please log in again.');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _diseaseResults.clear();
    });

    try {
      // Prepare request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(_getApiEndpoint()),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'multipart/form-data',
      });

      // Add image file - use 'imageFile' as the field name to match your backend
      if (kIsWeb && _webImage != null) {
        // For web, use bytes directly
        request.files.add(
          http.MultipartFile.fromBytes(
            'imageFile', // Changed from 'image' to 'imageFile'
            _webImage!,
            filename: 'image.jpg',
          ),
        );
      } else if (_image != null) {
        // For mobile/desktop, use file path
        request.files.add(
          await http.MultipartFile.fromPath('imageFile', _image!.path), // Changed from 'image' to 'imageFile'
        );
      }

      // Add comments if provided
      if (_commentsController.text.isNotEmpty) {
        request.fields['comments'] = _commentsController.text;
      }

      print('Sending disease identification request to: ${_getApiEndpoint()}');
      print('Selected crop: $_selectedCrop');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Disease identification response status: ${response.statusCode}');
      print('Disease identification response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        setState(() {
          _diseaseResults = _parseDiseaseResults(responseData);
          _isAnalyzing = false;
        });

        _showSuccessSnackBar('Disease analysis completed successfully!');
      } else if (response.statusCode == 401) {
        setState(() {
          _isAnalyzing = false;
        });
        _showErrorSnackBar('Authentication failed. Please log in again.');
      } else {
        setState(() {
          _isAnalyzing = false;
        });
        String errorMessage = 'Failed to analyze image: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // If can't parse error response, use default message
        }
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      print('Error analyzing image: $e');
      setState(() {
        _isAnalyzing = false;
      });
      _showErrorSnackBar('Failed to analyze image: Exception: $e');
    }
  }

  List<DiseaseResult> _parseDiseaseResults(Map<String, dynamic> response) {
    List<DiseaseResult> results = [];

    // Parse your actual backend response format
    if (response.containsKey('disease') && response.containsKey('confidence')) {
      String diseaseName = response['disease'] ?? 'Unknown Disease';
      double confidence = (response['confidence'] ?? 0.0).toDouble() * 100;
      
      // Create disease result with available data
      results.add(
        DiseaseResult(
          diseaseName: diseaseName,
          confidence: confidence,
          description: _getDescriptionForDisease(diseaseName),
          treatment: _getTreatmentForDisease(diseaseName),
          severity: _getSeverityForDisease(diseaseName, confidence),
        ),
      );

      // Add other probabilities if available
      if (response.containsKey('probabilities')) {
        Map<String, dynamic> probabilities = response['probabilities'];
        probabilities.forEach((disease, prob) {
          if (disease != diseaseName) { // Don't add the main result again
            double probability = (prob ?? 0.0).toDouble() * 100;
            if (probability > 10.0) { // Only show if probability is significant
              results.add(
                DiseaseResult(
                  diseaseName: disease,
                  confidence: probability,
                  description: _getDescriptionForDisease(disease),
                  treatment: _getTreatmentForDisease(disease),
                  severity: _getSeverityForDisease(disease, probability),
                ),
              );
            }
          }
        });
      }
    }

    // Sort by confidence (highest first)
    results.sort((a, b) => b.confidence.compareTo(a.confidence));

    return results;
  }

  String _getDescriptionForDisease(String disease) {
    Map<String, String> diseaseDescriptions = {
      'Early Blight': 'Dark spots with concentric rings on leaves, typically starts on older leaves',
      'Late Blight': 'Water-soaked spots on leaves and stems, can spread rapidly in cool, wet conditions',
      'Healthy': 'Plant appears healthy with no signs of disease',
      'Common Scab': 'Rough, corky patches on potato tubers',
      'Potato Virus Y': 'Mosaic patterns and leaf deformation',
      'Rice Blast': 'Diamond-shaped lesions on leaves',
      'Brown Spot': 'Brown spots with gray centers on rice leaves',
      'Bacterial Leaf Blight': 'Water-soaked lesions along leaf margins',
      'Sheath Blight': 'Oval to irregular lesions on leaf sheaths',
      'Powdery Mildew': 'White powdery growth on leaves',
      'Downy Mildew': 'Yellow patches with fuzzy growth underneath',
      'Bacterial Wilt': 'Sudden wilting of vines and leaves',
      'Anthracnose': 'Dark, sunken spots on fruits',
    };
    return diseaseDescriptions[disease] ?? 'No description available for this disease';
  }

  String _getTreatmentForDisease(String disease) {
    Map<String, String> diseaseTreatments = {
      'Early Blight': 'Apply copper-based fungicides, improve air circulation, remove affected leaves',
      'Late Blight': 'Use preventive fungicides, ensure good drainage, remove infected plants immediately',
      'Healthy': 'Continue regular monitoring and good agricultural practices',
      'Common Scab': 'Maintain soil pH below 5.2, avoid over-liming, use resistant varieties',
      'Potato Virus Y': 'Remove infected plants, control aphid vectors, use virus-free seed potatoes',
      'Rice Blast': 'Apply systemic fungicides, use resistant varieties, avoid excessive nitrogen',
      'Brown Spot': 'Improve soil fertility, apply appropriate fungicides, ensure proper spacing',
      'Bacterial Leaf Blight': 'Use copper-based bactericides, avoid overhead irrigation, use resistant varieties',
      'Sheath Blight': 'Apply fungicides at early stages, improve field drainage, reduce plant density',
      'Powdery Mildew': 'Apply sulfur or fungicides, improve air circulation, avoid overhead watering',
      'Downy Mildew': 'Use preventive fungicides, improve drainage, remove affected plants',
      'Bacterial Wilt': 'Remove infected plants, improve soil drainage, use resistant varieties',
      'Anthracnose': 'Apply fungicides, improve air circulation, remove infected fruits',
    };
    return diseaseTreatments[disease] ?? 'Consult with agricultural extension services for treatment advice';
  }

  String _getSeverityForDisease(String disease, double confidence) {
    if (disease == 'Healthy') return 'None';
    
    if (confidence >= 80) return 'High';
    if (confidence >= 60) return 'Medium';
    if (confidence >= 40) return 'Low';
    return 'Unknown';
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
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
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.red[400],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Image Source',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.green[600]),
                title: Text('Camera', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.green[600]),
                title: Text('Gallery', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCropSelectionSection(),
                    const SizedBox(height: 20),
                    _buildImageUploadSection(),
                    const SizedBox(height: 20),
                    _buildAnalyzeButton(),
                    const SizedBox(height: 25),
                    if (_diseaseResults.isNotEmpty) ...[
                      _buildResultsSection(),
                      const SizedBox(height: 20),
                    ],
                  ],
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
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  "Disease Identification",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "AI-powered crop-specific disease detection and treatment recommendations",
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

  Widget _buildCropSelectionSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Theme.of(context).cardTheme.color,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Crop Type',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose the type of crop you want to analyze for diseases',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              children:
                  _cropTypes.map((crop) {
                    bool isSelected = _selectedCrop == crop['value'];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCrop = crop['value']!;
                            _diseaseResults
                                .clear(); // Clear previous results when crop changes
                            _image = null;
                            _webImage = null;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors:
                                  isSelected
                                      ? [Colors.green[400]!, Colors.green[500]!]
                                      : [Colors.grey[100]!, Colors.grey[200]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? Colors.green[600]!
                                      : Colors.grey[300]!,
                              width: 2,
                            ),
                            boxShadow:
                                isSelected
                                    ? [
                                      BoxShadow(
                                        color: Colors.green[300]!.withOpacity(
                                          0.5,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                    : null,
                          ),
                          child: Column(
                            children: [
                              Text(
                                crop['icon']!,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                crop['name']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors.grey[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Selected: ${_cropTypes.firstWhere((crop) => crop['value'] == _selectedCrop)['name']} - Our AI will analyze diseases specific to this crop',
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

  Widget _buildImageUploadSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload ${_cropTypes.firstWhere((crop) => crop['value'] == _selectedCrop)['name']} Image',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Take a clear photo of the affected $_selectedCrop plant for accurate diagnosis',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _image != null ? Colors.transparent : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green[300]!,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child:
                    (_image != null || _webImage != null)
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child:
                              kIsWeb && _webImage != null
                                  ? Image.memory(
                                    _webImage!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                  : _image != null
                                  ? Image.file(
                                    _image!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                  : Container(),
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 48,
                              color: Colors.green[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap to select image',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.green[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Camera or Gallery',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              _isAnalyzing || (_image == null && _webImage == null)
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
        onPressed:
            (_isAnalyzing || (_image == null && _webImage == null))
                ? null
                : _analyzeImage,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child:
            _isAnalyzing
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
                      'Analyzing Image...',
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
                    const Icon(Icons.biotech, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Analyze Disease',
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

  Widget _buildResultsSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.green[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
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
                  child: Icon(
                    Icons.medical_services,
                    color: Colors.green[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Disease Analysis Results',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            for (int i = 0; i < _diseaseResults.length; i++) ...[
              _buildDiseaseResultCard(_diseaseResults[i]),
              if (i < _diseaseResults.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseResultCard(DiseaseResult result) {
    Color severityColor = _getSeverityColor(result.severity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  result.diseaseName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: severityColor),
                ),
                child: Text(
                  result.severity,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: severityColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Confidence: ',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${result.confidence.toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Description:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            result.description,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          Text(
            'Treatment:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            result.treatment,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
      case 'severe':
        return Colors.red;
      case 'medium':
      case 'moderate':
        return Colors.orange;
      case 'low':
      case 'mild':
        return Colors.yellow[700]!;
      default:
        return Colors.blue;
    }
  }
}