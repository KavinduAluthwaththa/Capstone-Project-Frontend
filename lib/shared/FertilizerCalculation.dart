import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Fertilizing extends StatefulWidget {
  const Fertilizing({super.key});

  @override
  _FertilizingState createState() => _FertilizingState();
}

class _FertilizingState extends State<Fertilizing> {
  bool taskCompleted = false;
  String? selectedCrop;
  String? selectedFertilizer;
  String? selectedAreaUnit = 'acres';
  TextEditingController areaController = TextEditingController();
  double? amountToUse;
  String? recommendation;
  bool isLoading = false;

  // Enhanced crop and fertilizer data with proper NPK values
  final Map<String, Map<String, dynamic>> crops = {
    'Rice': {
      'N': 80, // kg/hectare
      'P': 40,
      'K': 40,
      'seasons': ['Yala', 'Maha'],
      'description': 'Sri Lankan staple crop requiring balanced nutrition'
    },
    'Wheat': {
      'N': 120,
      'P': 60,
      'K': 40,
      'seasons': ['Yala'],
      'description': 'High nitrogen requirement cereal crop'
    },
    'Corn (Maize)': {
      'N': 150,
      'P': 75,
      'K': 75,
      'seasons': ['Year-round'],
      'description': 'Heavy feeder requiring high nutrient input'
    },
    'Potato': {
      'N': 100,
      'P': 50,
      'K': 150,
      'seasons': ['Yala'],
      'description': 'High potassium requirement for tuber development'
    },
    'Tomato': {
      'N': 120,
      'P': 80,
      'K': 120,
      'seasons': ['Year-round'],
      'description': 'Fruit crop with high nutrient demands'
    },
    'Cabbage': {
      'N': 100,
      'P': 50,
      'K': 100,
      'seasons': ['Year-round'],
      'description': 'Leafy vegetable requiring balanced nutrition'
    },
    'Carrot': {
      'N': 80,
      'P': 60,
      'K': 120,
      'seasons': ['Year-round'],
      'description': 'Root crop with moderate nutrient needs'
    },
    'Bean': {
      'N': 30, // Lower due to nitrogen fixation
      'P': 40,
      'K': 60,
      'seasons': ['Year-round'],
      'description': 'Legume crop that fixes nitrogen naturally'
    }
  };

  final Map<String, Map<String, dynamic>> fertilizers = {
    'Urea': {
      'N': 46,
      'P': 0,
      'K': 0,
      'cost_per_kg': 85, // LKR
      'description': 'High nitrogen fertilizer for vegetative growth'
    },
    'Triple Super Phosphate (TSP)': {
      'N': 0,
      'P': 46,
      'K': 0,
      'cost_per_kg': 120,
      'description': 'Phosphate fertilizer for root development'
    },
    'Muriate of Potash (MOP)': {
      'N': 0,
      'P': 0,
      'K': 60,
      'cost_per_kg': 110,
      'description': 'Potassium fertilizer for fruit quality'
    },
    'NPK 15:15:15': {
      'N': 15,
      'P': 15,
      'K': 15,
      'cost_per_kg': 95,
      'description': 'Balanced fertilizer for general use'
    },
    'NPK 20:10:10': {
      'N': 20,
      'P': 10,
      'K': 10,
      'cost_per_kg': 100,
      'description': 'High nitrogen blend for leafy crops'
    },
    'DAP (Diammonium Phosphate)': {
      'N': 18,
      'P': 46,
      'K': 0,
      'cost_per_kg': 130,
      'description': 'Nitrogen-phosphate fertilizer for early growth'
    },
    'Compost': {
      'N': 1.5,
      'P': 1.0,
      'K': 1.5,
      'cost_per_kg': 15,
      'description': 'Organic fertilizer for soil health'
    }
  };

  final List<String> areaUnits = ['acres', 'hectares', 'perches'];

  @override
  void initState() {
    super.initState();
    _saveUsageData();
  }

  @override
  void dispose() {
    areaController.dispose();
    super.dispose();
  }

  Future<void> _saveUsageData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt('feature_usage_fertilizer_calculation') ?? 0;
      await prefs.setInt('feature_usage_fertilizer_calculation', currentCount + 1);
      await prefs.setString('last_used_feature', 'fertilizer_calculation');
      await prefs.setString('last_activity_time', DateTime.now().toIso8601String());
    } catch (e) {
      print('Error saving usage data: $e');
    }
  }

  double convertToHectares(double area, String unit) {
    switch (unit) {
      case 'acres':
        return area * 0.4047; // 1 acre = 0.4047 hectares
      case 'perches':
        return area * 0.00101; // 1 perch = 0.00101 hectares (Sri Lankan perch)
      case 'hectares':
      default:
        return area;
    }
  }

  Map<String, dynamic> calculateFertilizerAmount(String crop, String fertilizer, double area, String unit) {
    if (!crops.containsKey(crop) || !fertilizers.containsKey(fertilizer)) {
      return {'error': 'Invalid crop or fertilizer selection'};
    }

    double areaInHectares = convertToHectares(area, unit);
    
    final cropData = crops[crop]!;
    final fertilizerData = fertilizers[fertilizer]!;

    // Required nutrients for the crop (kg/hectare)
    double requiredN = cropData['N'].toDouble();
    double requiredP = cropData['P'].toDouble();
    double requiredK = cropData['K'].toDouble();

    // Nutrient content in fertilizer (%)
    double fertilizerN = fertilizerData['N'].toDouble();
    double fertilizerP = fertilizerData['P'].toDouble();
    double fertilizerK = fertilizerData['K'].toDouble();

    // Calculate fertilizer amount needed to meet primary nutrient requirement
    double fertilizerAmount = 0;
    String primaryNutrient = '';
    
    if (fertilizerN > 0) {
      fertilizerAmount = (requiredN * areaInHectares * 100) / fertilizerN;
      primaryNutrient = 'Nitrogen';
    } else if (fertilizerP > 0) {
      fertilizerAmount = (requiredP * areaInHectares * 100) / fertilizerP;
      primaryNutrient = 'Phosphorus';
    } else if (fertilizerK > 0) {
      fertilizerAmount = (requiredK * areaInHectares * 100) / fertilizerK;
      primaryNutrient = 'Potassium';
    }

    // Calculate cost
    double totalCost = fertilizerAmount * fertilizerData['cost_per_kg'];

    // Generate recommendations
    String recommendations = _generateRecommendations(crop, fertilizer, fertilizerAmount, areaInHectares);

    return {
      'amount': fertilizerAmount,
      'cost': totalCost,
      'primary_nutrient': primaryNutrient,
      'recommendations': recommendations,
      'area_hectares': areaInHectares,
      'nutrient_provided': {
        'N': (fertilizerAmount * fertilizerN) / 100,
        'P': (fertilizerAmount * fertilizerP) / 100,
        'K': (fertilizerAmount * fertilizerK) / 100,
      },
      'nutrient_required': {
        'N': requiredN * areaInHectares,
        'P': requiredP * areaInHectares,
        'K': requiredK * areaInHectares,
      }
    };
  }

  String _generateRecommendations(String crop, String fertilizer, double amount, double area) {
    String recommendations = "Application Guidelines:\n\n";
    
    // Application timing
    if (fertilizer.contains('Urea') || fertilizer.contains('NPK')) {
      recommendations += "• Apply in 2-3 split doses during growing season\n";
      recommendations += "• First application: 25% at planting\n";
      recommendations += "• Second application: 50% at 4-6 weeks\n";
      recommendations += "• Third application: 25% at flowering stage\n\n";
    } else if (fertilizer.contains('TSP') || fertilizer.contains('DAP')) {
      recommendations += "• Apply full amount at planting time\n";
      recommendations += "• Mix well with soil before sowing\n\n";
    } else if (fertilizer.contains('Compost')) {
      recommendations += "• Apply 2-3 weeks before planting\n";
      recommendations += "• Mix thoroughly with soil\n\n";
    }

    // Application method
    recommendations += "Application Method:\n";
    recommendations += "• Apply during cool hours (early morning/evening)\n";
    recommendations += "• Ensure soil is moist but not waterlogged\n";
    recommendations += "• Keep fertilizer away from plant stems\n";
    recommendations += "• Water lightly after application\n\n";

    // Safety precautions
    recommendations += "Safety Precautions:\n";
    recommendations += "• Wear gloves and protective clothing\n";
    recommendations += "• Store in cool, dry place away from children\n";
    recommendations += "• Do not apply before heavy rain\n";

    return recommendations;
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildCropSelection(),
                    const SizedBox(height: 20),
                    _buildFertilizerSelection(),
                    const SizedBox(height: 20),
                    _buildAreaInput(),
                    const SizedBox(height: 30),
                    _buildActionButtons(),
                    const SizedBox(height: 30),
                    if (taskCompleted && amountToUse != null) _buildResults(),
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
                  "Fertilizer Calculator",
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
            "Calculate optimal fertilizer amounts for your crops",
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

  Widget _buildCropSelection() {
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
            Row(
              children: [
                Icon(Icons.grass, color: Colors.green[400], size: 24),
                const SizedBox(width: 12),
                Text(
                  "Select Crop Type",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: _inputDecoration(),
              value: selectedCrop,
              hint: Text(
                "Choose your crop",
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
              onChanged: (value) {
                setState(() {
                  selectedCrop = value;
                  taskCompleted = false;
                  amountToUse = null;
                });
              },
              items: crops.keys
                  .map((crop) => DropdownMenuItem(
                        value: crop,
                        child: Text(
                          crop,
                          style: GoogleFonts.poppins(),
                        ),
                      ))
                  .toList(),
            ),
            if (selectedCrop != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  crops[selectedCrop]!['description'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFertilizerSelection() {
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
            Row(
              children: [
                Icon(Icons.science, color: Colors.green[400], size: 24),
                const SizedBox(width: 12),
                Text(
                  "Select Fertilizer Type",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: _inputDecoration(),
              value: selectedFertilizer,
              hint: Text(
                "Choose fertilizer",
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
              onChanged: (value) {
                setState(() {
                  selectedFertilizer = value;
                  taskCompleted = false;
                  amountToUse = null;
                });
              },
              items: fertilizers.keys
                  .map((fertilizer) => DropdownMenuItem(
                        value: fertilizer,
                        child: Text(
                          fertilizer,
                          style: GoogleFonts.poppins(),
                        ),
                      ))
                  .toList(),
            ),
            if (selectedFertilizer != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fertilizers[selectedFertilizer]!['description'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'NPK: ${fertilizers[selectedFertilizer]!['N']}:${fertilizers[selectedFertilizer]!['P']}:${fertilizers[selectedFertilizer]!['K']} | Cost: LKR ${fertilizers[selectedFertilizer]!['cost_per_kg']}/kg',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[600],
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

  Widget _buildAreaInput() {
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
            Row(
              children: [
                Icon(Icons.landscape, color: Colors.green[400], size: 24),
                const SizedBox(width: 12),
                Text(
                  "Land Area",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: areaController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration().copyWith(
                      hintText: "Enter area",
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                    ),
                    style: GoogleFonts.poppins(),
                    onChanged: (value) {
                      setState(() {
                        taskCompleted = false;
                        amountToUse = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: _inputDecoration(),
                    value: selectedAreaUnit,
                    onChanged: (value) {
                      setState(() {
                        selectedAreaUnit = value;
                        taskCompleted = false;
                        amountToUse = null;
                      });
                    },
                    items: areaUnits
                        .map((unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(
                                unit,
                                style: GoogleFonts.poppins(),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[400],
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 2,
            ),
            onPressed: isLoading ? null : _calculateFertilizer,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calculate, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Calculate',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 2,
            ),
            onPressed: _resetForm,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.refresh, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Reset',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
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
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.green[400], size: 24),
                const SizedBox(width: 12),
                Text(
                  "Calculation Results",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Amount and cost display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Required Amount:",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "${amountToUse!.toStringAsFixed(1)} kg",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Estimated Cost:",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "LKR ${(amountToUse! * fertilizers[selectedFertilizer]!['cost_per_kg']).toStringAsFixed(0)}",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            if (recommendation != null) ...[
              const SizedBox(height: 20),
              Text(
                "Application Guidelines",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  recommendation!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.blue[700],
                    height: 1.5,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            _buildSuccessIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIndicator() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.assignment_turned_in,
            size: 60,
            color: Colors.green[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Calculation Complete',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          Text(
            'Follow the guidelines for best results',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _calculateFertilizer() {
    if (selectedCrop == null || selectedFertilizer == null || areaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all fields',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double? area = double.tryParse(areaController.text);
    if (area == null || area <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid area',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Simulate calculation delay
    Future.delayed(const Duration(seconds: 1), () {
      final result = calculateFertilizerAmount(
        selectedCrop!,
        selectedFertilizer!,
        area,
        selectedAreaUnit!,
      );

      if (result.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['error'],
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        setState(() {
          amountToUse = result['amount'];
          recommendation = result['recommendations'];
          taskCompleted = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Fertilizer calculation completed successfully!',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.green[400],
          ),
        );
      }

      setState(() {
        isLoading = false;
      });
    });
  }

  void _resetForm() {
    setState(() {
      selectedCrop = null;
      selectedFertilizer = null;
      selectedAreaUnit = 'acres';
      areaController.clear();
      amountToUse = null;
      recommendation = null;
      taskCompleted = false;
    });
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.green[400]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }
}