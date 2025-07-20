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
      'cost_per_kg': 85, // LKR
      'description': 'High nitrogen fertilizer for vegetative growth',
    },
    'Triple Super Phosphate (TSP)': {
      'N': 0,
      'P': 46,
      'K': 0,
      'cost_per_kg': 120,
      'description': 'Phosphate fertilizer for root development',
    },
    'Muriate of Potash (MOP)': {
      'N': 0,
      'P': 0,
      'K': 60,
      'cost_per_kg': 110,
      'description': 'Potassium fertilizer for fruit quality',
    },
    'NPK 15:15:15': {
      'N': 15,
      'P': 15,
      'K': 15,
      'cost_per_kg': 95,
      'description': 'Balanced fertilizer for general use',
    },
    'NPK 20:10:10': {
      'N': 20,
      'P': 10,
      'K': 10,
      'cost_per_kg': 100,
      'description': 'High nitrogen blend for leafy crops',
    },
    'DAP (Diammonium Phosphate)': {
      'N': 18,
      'P': 46,
      'K': 0,
      'cost_per_kg': 130,
      'description': 'Nitrogen-phosphate fertilizer for early growth',
    },
    'Compost': {
      'N': 1.5,
      'P': 1.0,
      'K': 1.5,
      'cost_per_kg': 15,
      'description': 'Organic fertilizer for soil health',
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
    double fertilizerN =
        fertilizerData['N'].toDouble() / 100; // Convert % to decimal
    double fertilizerP = fertilizerData['P'].toDouble() / 100;
    double fertilizerK = fertilizerData['K'].toDouble() / 100;

    // Calculate fertilizer amount needed using the formula:
    // Fertilizer rate = (Required nutrient application rate × 100) / (% nutrient in fertilizer × W)
    // Where W is the weight factor (we'll use 1 for direct calculation)

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
    } else if (fertilizerAmounts.containsKey('P') &&
        fertilizerAmounts['P']! > 0) {
      finalFertilizerAmount = fertilizerAmounts['P']!;
      primaryNutrient = 'Phosphorus (P)';
      calculationMethod = 'Calculated based on Phosphorus requirement';
    } else if (fertilizerAmounts.containsKey('K') &&
        fertilizerAmounts['K']! > 0) {
      finalFertilizerAmount = fertilizerAmounts['K']!;
      primaryNutrient = 'Potassium (K)';
      calculationMethod = 'Calculated based on Potassium requirement';
    }

    // Calculate actual nutrients provided (convert back from percentage)
    double actualN =
        (finalFertilizerAmount * fertilizerData['N'].toDouble()) / 100;
    double actualP =
        (finalFertilizerAmount * fertilizerData['P'].toDouble()) / 100;
    double actualK =
        (finalFertilizerAmount * fertilizerData['K'].toDouble()) / 100;

    // Calculate application rate per 1000 sq ft (standard reference)
    double applicationRatePer1000SqFt =
        (finalFertilizerAmount * 1000) / (areaInSqFt);

    // Calculate cost
    double totalCost = finalFertilizerAmount * fertilizerData['cost_per_kg'];

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
      'cost': totalCost,
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
    String recommendations = "📊 FERTILIZER CALCULATION SUMMARY\n\n";

    // Calculation details
    recommendations += "🧮 Calculation Method:\n";
    recommendations +=
        "Formula Used: Fertilizer rate = (Required nutrient application rate × 100) / (% nutrient in fertilizer × W)\n";
    recommendations +=
        "Where W = weight factor (typically 1 for direct calculation)\n";
    recommendations += "Primary Nutrient: $primaryNutrient\n";
    recommendations +=
        "Application Rate: ${applicationRatePer1000SqFt.toStringAsFixed(2)} kg per 1000 sq ft\n\n";

    // Nutrient analysis
    recommendations += "🌱 NUTRIENT ANALYSIS\n";
    recommendations += "Nutrients Provided vs Required:\n";
    recommendations +=
        "• Nitrogen (N): ${actualN.toStringAsFixed(1)} kg provided | ${requiredN.toStringAsFixed(1)} kg required\n";
    recommendations +=
        "• Phosphorus (P): ${actualP.toStringAsFixed(1)} kg provided | ${requiredP.toStringAsFixed(1)} kg required\n";
    recommendations +=
        "• Potassium (K): ${actualK.toStringAsFixed(1)} kg provided | ${requiredK.toStringAsFixed(1)} kg required\n\n";

    // Nutrient sufficiency warnings
    if (actualN < requiredN && actualN > 0) {
      recommendations +=
          "⚠️ WARNING: Nitrogen deficiency! Consider supplementing with additional nitrogen fertilizer.\n";
    }
    if (actualP < requiredP && actualP > 0) {
      recommendations +=
          "⚠️ WARNING: Phosphorus deficiency! Consider supplementing with phosphate fertilizer.\n";
    }
    if (actualK < requiredK && actualK > 0) {
      recommendations +=
          "⚠️ WARNING: Potassium deficiency! Consider supplementing with potash fertilizer.\n";
    }

    recommendations += "\n📅 APPLICATION SCHEDULE\n";

    // Application timing based on fertilizer type
    if (fertilizer.contains('Urea') || fertilizer.contains('NPK')) {
      recommendations += "Split Application Recommended:\n";
      recommendations +=
          "• 1st Application (Planting): ${(amount * 0.25).toStringAsFixed(1)} kg (25%)\n";
      recommendations +=
          "• 2nd Application (4-6 weeks): ${(amount * 0.50).toStringAsFixed(1)} kg (50%)\n";
      recommendations +=
          "• 3rd Application (Flowering): ${(amount * 0.25).toStringAsFixed(1)} kg (25%)\n\n";
    } else if (fertilizer.contains('TSP') || fertilizer.contains('DAP')) {
      recommendations += "Single Application at Planting:\n";
      recommendations +=
          "• Apply full amount: ${amount.toStringAsFixed(1)} kg at soil preparation\n";
      recommendations += "• Mix thoroughly with soil before sowing\n\n";
    } else if (fertilizer.contains('Compost')) {
      recommendations += "Pre-planting Application:\n";
      recommendations +=
          "• Apply 2-3 weeks before planting: ${amount.toStringAsFixed(1)} kg\n";
      recommendations += "• Allow decomposition time\n\n";
    } else {
      recommendations += "Standard Application:\n";
      recommendations +=
          "• Total amount needed: ${amount.toStringAsFixed(1)} kg\n";
      recommendations += "• Apply in 2-3 split doses for best results\n\n";
    }

    // Application method
    recommendations += "🚜 APPLICATION METHOD\n";
    recommendations +=
        "• Apply during cool hours (early morning 6-8 AM or evening 4-6 PM)\n";
    recommendations +=
        "• Ensure soil moisture is adequate but not waterlogged\n";
    recommendations += "• Maintain 2-3 cm distance from plant stems\n";
    recommendations +=
        "• Water lightly after application to activate nutrients\n";
    recommendations += "• Incorporate into soil if surface applied\n\n";

    // Environmental considerations
    recommendations += "🌍 ENVIRONMENTAL GUIDELINES\n";
    recommendations +=
        "• Avoid application before heavy rain (>25mm predicted)\n";
    recommendations += "• Do not apply on frozen or waterlogged soil\n";
    recommendations +=
        "• Consider soil pH - optimal range 6.0-7.0 for most crops\n";
    recommendations += "• Monitor for nutrient runoff in sloped areas\n\n";

    // Safety and storage
    recommendations += "⚠️ SAFETY PRECAUTIONS\n";
    recommendations +=
        "• Wear protective equipment: gloves, mask, long sleeves\n";
    recommendations +=
        "• Store in cool, dry place away from children and pets\n";
    recommendations +=
        "• Keep fertilizer bags sealed to prevent moisture absorption\n";
    recommendations += "• Wash hands thoroughly after handling\n";
    recommendations += "• Do not smoke or eat while applying fertilizer\n\n";

    // Cost and efficiency tips
    recommendations += "💡 EFFICIENCY TIPS\n";
    recommendations +=
        "• Conduct soil test before application for precise nutrient needs\n";
    recommendations +=
        "• Consider slow-release fertilizers for reduced application frequency\n";
    recommendations +=
        "• Monitor crop response and adjust future applications accordingly\n";
    recommendations +=
        "• Combine with organic matter to improve soil structure\n";

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
                  "Fertilizer Calculation Results",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Enhanced amount and cost display
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
                        "Total Fertilizer Required:",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "${amountToUse!.toStringAsFixed(1)} kg",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
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
                        "Selected Crop:",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
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
                      Text(
                        "Fertilizer Type:",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      Flexible(
                        child: Text(
                          selectedFertilizer!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[600],
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Application Area:",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
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

            // Scientific calculation info
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.science, color: Colors.blue[600], size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Scientific Calculation",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Formula: Fertilizer rate = (Required nutrient application rate × 100) / (% nutrient in fertilizer × W)",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.blue[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "NPK Content: ${fertilizers[selectedFertilizer]!['N']}% - ${fertilizers[selectedFertilizer]!['P']}% - ${fertilizers[selectedFertilizer]!['K']}%",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            if (recommendation != null) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.assignment, color: Colors.green[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Detailed Application Guidelines",
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
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    recommendation!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
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
