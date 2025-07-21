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
  Map<String, dynamic>? calculationResults;

  // Enhanced crop and fertilizer data with proper NPK values
  final Map<String, Map<String, dynamic>> crops = {
    'Rice': {
      'N': 80, // kg/hectare
      'P': 40,
      'K': 40,
      'seasons': ['Yala', 'Maha'],
      'description': 'Sri Lankan staple crop requiring balanced nutrition',
    },
    'Wheat': {
      'N': 120,
      'P': 60,
      'K': 40,
      'seasons': ['Yala'],
      'description': 'High nitrogen requirement cereal crop',
    },
    'Corn (Maize)': {
      'N': 150,
      'P': 75,
      'K': 75,
      'seasons': ['Year-round'],
      'description': 'Heavy feeder requiring high nutrient input',
    },
    'Potato': {
      'N': 100,
      'P': 50,
      'K': 150,
      'seasons': ['Yala'],
      'description': 'High potassium requirement for tuber development',
    },
    'Tomato': {
      'N': 120,
      'P': 80,
      'K': 120,
      'seasons': ['Year-round'],
      'description': 'Fruit crop with high nutrient demands',
    },
    'Cabbage': {
      'N': 100,
      'P': 50,
      'K': 100,
      'seasons': ['Year-round'],
      'description': 'Leafy vegetable requiring balanced nutrition',
    },
    'Carrot': {
      'N': 80,
      'P': 60,
      'K': 120,
      'seasons': ['Year-round'],
      'description': 'Root crop with moderate nutrient needs',
    },
    'Bean': {
      'N': 30, // Lower due to nitrogen fixation
      'P': 40,
      'K': 60,
      'seasons': ['Year-round'],
      'description': 'Legume crop that fixes nitrogen naturally',
    },
  };

  final Map<String, Map<String, dynamic>> fertilizers = {
    'Urea': {
      'N': 46,
      'P': 0,
      'K': 0,
      'description': 'High nitrogen fertilizer for vegetative growth',
    },
    'Triple Super Phosphate (TSP)': {
      'N': 0,
      'P': 46,
      'K': 0,
      'description': 'Phosphate fertilizer for root development',
    },
    'Muriate of Potash (MOP)': {
      'N': 0,
      'P': 0,
      'K': 60,
      'description': 'Potassium fertilizer for fruit quality',
    },
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
      final currentCount =
          prefs.getInt('feature_usage_fertilizer_calculation') ?? 0;
      await prefs.setInt(
        'feature_usage_fertilizer_calculation',
        currentCount + 1,
      );
      await prefs.setString('last_used_feature', 'fertilizer_calculation');
      await prefs.setString(
        'last_activity_time',
        DateTime.now().toIso8601String(),
      );
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

  Map<String, dynamic> calculateFertilizerAmount(
    String crop,
    String fertilizer,
    double area,
    String unit,
  ) {
    if (!crops.containsKey(crop) || !fertilizers.containsKey(fertilizer)) {
      return {'error': 'Invalid crop or fertilizer selection'};
    }

    // Convert area to standard unit (hectares for metric, then convert to square feet for calculations)
    double areaInHectares = convertToHectares(area, unit);
    double areaInSqFt = areaInHectares * 107639; // 1 hectare = 107,639 sq ft

    final cropData = crops[crop]!;
    final fertilizerData = fertilizers[fertilizer]!;

    // Required nutrients for the crop (kg/hectare)
    double requiredN = cropData['N'].toDouble();
    double requiredP = cropData['P'].toDouble();
    double requiredK = cropData['K'].toDouble();

    // Nutrient content in fertilizer (%)
    double fertilizerN = fertilizerData['N'].toDouble() / 100;
    double fertilizerP = fertilizerData['P'].toDouble() / 100;
    double fertilizerK = fertilizerData['K'].toDouble() / 100;

    Map<String, double> fertilizerAmounts = {};
    Map<String, double> nutrientDeficiencies = {};

    // Calculate for each nutrient
    if (fertilizerN > 0) {
      // Required N in kg for the total area
      double totalNRequired = requiredN * areaInHectares;
      // Apply the formula: (Required nutrient × 100) / (% nutrient × W)
      fertilizerAmounts['N'] =
          (totalNRequired * 100) / (fertilizerData['N'].toDouble() * 1);
      nutrientDeficiencies['N'] = totalNRequired;
    }

    if (fertilizerP > 0) {
      double totalPRequired = requiredP * areaInHectares;
      fertilizerAmounts['P'] =
          (totalPRequired * 100) / (fertilizerData['P'].toDouble() * 1);
      nutrientDeficiencies['P'] = totalPRequired;
    }

    if (fertilizerK > 0) {
      double totalKRequired = requiredK * areaInHectares;
      fertilizerAmounts['K'] =
          (totalKRequired * 100) / (fertilizerData['K'].toDouble() * 1);
      nutrientDeficiencies['K'] = totalKRequired;
    }

    // Determine the primary nutrient and calculate based on the limiting factor
    double finalFertilizerAmount = 0;
    String primaryNutrient = '';
    String calculationMethod = '';

    if (fertilizerAmounts.containsKey('N') && fertilizerAmounts['N']! > 0) {
      finalFertilizerAmount = fertilizerAmounts['N']!;
      primaryNutrient = 'Nitrogen (N)';
      calculationMethod = 'Calculated based on Nitrogen requirement';
    } else if (fertilizerAmounts.containsKey('P') && fertilizerAmounts['P']! > 0) {
      finalFertilizerAmount = fertilizerAmounts['P']!;
      primaryNutrient = 'Phosphorus (P)';
      calculationMethod = 'Calculated based on Phosphorus requirement';
    } else if (fertilizerAmounts.containsKey('K') && fertilizerAmounts['K']! > 0) {
      finalFertilizerAmount = fertilizerAmounts['K']!;
      primaryNutrient = 'Potassium (K)';
      calculationMethod = 'Calculated based on Potassium requirement';
    }

    // Calculate actual nutrients provided
    double actualN = (finalFertilizerAmount * fertilizerData['N'].toDouble()) / 100;
    double actualP = (finalFertilizerAmount * fertilizerData['P'].toDouble()) / 100;
    double actualK = (finalFertilizerAmount * fertilizerData['K'].toDouble()) / 100;

    // Calculate application rate per 1000 sq ft
    double applicationRatePer1000SqFt = (finalFertilizerAmount * 1000) / (areaInSqFt);

    // Generate detailed recommendations
    String recommendations = _generateDetailedRecommendations(
      crop,
      fertilizer,
      finalFertilizerAmount,
      areaInHectares,
      applicationRatePer1000SqFt,
      primaryNutrient,
      actualN,
      actualP,
      actualK,
      requiredN * areaInHectares,
      requiredP * areaInHectares,
      requiredK * areaInHectares,
    );

    return {
      'amount': finalFertilizerAmount,
      'primary_nutrient': primaryNutrient,
      'calculation_method': calculationMethod,
      'application_rate_per_1000sqft': applicationRatePer1000SqFt,
      'recommendations': recommendations,
      'area_hectares': areaInHectares,
      'area_sqft': areaInSqFt,
      'nutrient_provided': {'N': actualN, 'P': actualP, 'K': actualK},
      'nutrient_required': {
        'N': requiredN * areaInHectares,
        'P': requiredP * areaInHectares,
        'K': requiredK * areaInHectares,
      },
      'nutrient_sufficiency': {
        'N': actualN >= (requiredN * areaInHectares),
        'P': actualP >= (requiredP * areaInHectares),
        'K': actualK >= (requiredK * areaInHectares),
      },
      'fertilizer_percentage': {
        'N': fertilizerData['N'],
        'P': fertilizerData['P'],
        'K': fertilizerData['K'],
      },
    };
  }

  String _generateDetailedRecommendations(
    String crop,
    String fertilizer,
    double amount,
    double area,
    double applicationRatePer1000SqFt,
    String primaryNutrient,
    double actualN,
    double actualP,
    double actualK,
    double requiredN,
    double requiredP,
    double requiredK,
  ) {
    String recommendations = "📊 FERTILIZER APPLICATION GUIDE\n\n";

    // Amount summary
    recommendations += "🧮 Amount Required:\n";
    recommendations += "Total: ${amount.toStringAsFixed(1)} kg for ${area.toStringAsFixed(2)} hectares\n\n";

    // Simple application method based on fertilizer type
    recommendations += "📅 HOW TO APPLY:\n";

    if (fertilizer.contains('Urea')) {
      recommendations += "UREA APPLICATION:\n";
      recommendations += "• Split into 3 applications:\n";
      recommendations += "  - 1st: ${(amount * 0.25).toStringAsFixed(1)} kg at planting\n";
      recommendations += "  - 2nd: ${(amount * 0.50).toStringAsFixed(1)} kg after 4-6 weeks\n";
      recommendations += "  - 3rd: ${(amount * 0.25).toStringAsFixed(1)} kg at flowering\n";
      recommendations += "• Apply early morning or evening\n";
      recommendations += "• Keep 2-3 cm away from plant stems\n";
      recommendations += "• Water lightly after application\n\n";
      
    } else if (fertilizer.contains('TSP')) {
      recommendations += "TSP APPLICATION:\n";
      recommendations += "• Apply full amount: ${amount.toStringAsFixed(1)} kg\n";
      recommendations += "• Apply once at soil preparation before planting\n";
      recommendations += "• Mix thoroughly with soil\n";
      recommendations += "• Apply 1-2 weeks before sowing seeds\n";
      recommendations += "• No need to split - single application only\n\n";
      
    } else if (fertilizer.contains('MOP')) {
      recommendations += "MOP APPLICATION:\n";
      recommendations += "• Split into 2 applications:\n";
      recommendations += "  - 1st: ${(amount * 0.60).toStringAsFixed(1)} kg at planting\n";
      recommendations += "  - 2nd: ${(amount * 0.40).toStringAsFixed(1)} kg during fruit development\n";
      recommendations += "• Apply in cool hours (morning/evening)\n";
      recommendations += "• Ensure adequate soil moisture\n";
      recommendations += "• Mix with soil surface\n\n";
    }

    // Simple safety tips
    recommendations += "⚠️ SAFETY:\n";
    recommendations += "• Wear gloves and mask\n";
    recommendations += "• Store in dry place\n";
    recommendations += "• Wash hands after use\n";
    recommendations += "• Don't apply before heavy rain\n\n";

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
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.maybePop(context),
              ),
              Expanded(
                child: Text(
                  "Fertilizer Calculator",
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
            "Calculate optimal fertilizer amounts for your crops",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCropSelection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
              items:
                  crops.keys
                      .map(
                        (crop) => DropdownMenuItem(
                          value: crop,
                          child: Text(crop, style: GoogleFonts.poppins()),
                        ),
                      )
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
              items:
                  fertilizers.keys
                      .map(
                        (fertilizer) => DropdownMenuItem(
                          value: fertilizer,
                          child: Text(fertilizer, style: GoogleFonts.poppins()),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaInput() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                    items:
                        areaUnits
                            .map(
                              (unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(unit, style: GoogleFonts.poppins()),
                              ),
                            )
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
            child:
                isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calculate,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Calculate',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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

            // Simple amount display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[50]!, Colors.green[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Amount Required:",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "${amountToUse!.toStringAsFixed(1)} kg",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.green[300]),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Crop:", style: GoogleFonts.poppins(fontSize: 14)),
                      Text(
                        selectedCrop!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Fertilizer:", style: GoogleFonts.poppins(fontSize: 14)),
                      Text(
                        selectedFertilizer!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Area:", style: GoogleFonts.poppins(fontSize: 14)),
                      Text(
                        "${areaController.text} $selectedAreaUnit",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (recommendation != null) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Application Instructions",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  recommendation!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.blue[800],
                    height: 1.4,
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
          Icon(Icons.assignment_turned_in, size: 60, color: Colors.green[400]),
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
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _calculateFertilizer() {
    if (selectedCrop == null ||
        selectedFertilizer == null ||
        areaController.text.isEmpty) {
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
          calculationResults = result;
          amountToUse = result['amount'];
          recommendation = result['recommendations'];
          taskCompleted = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Fertilizer calculation completed using scientific formula!',
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
      calculationResults = null;
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
