import 'package:flutter/material.dart';

class Fertilizing extends StatefulWidget {
  const Fertilizing({super.key});

  @override
  _FertilizingState createState() => _FertilizingState();
}

class _FertilizingState extends State<Fertilizing> {
  bool taskCompleted = false;
  String? selectedCrop;
  String? selectedFertilizer;
  TextEditingController areaController = TextEditingController();
  double? amountToUse;

  List<String> crops = ['Wheat', 'Corn', 'Rice'];
  List<String> fertilizers = ['Urea', 'DAP', 'Compost'];

  // Example calculation logic (replace with your real logic)
  double calculateAmount(String crop, String fertilizer, double area) {
    // Dummy logic: you can replace this with your actual calculation
    double base = 0;
    if (crop == 'Wheat') base = 10;
    if (crop == 'Corn') base = 12;
    if (crop == 'Rice') base = 8;

    if (fertilizer == 'Urea') base *= 1.0;
    if (fertilizer == 'DAP') base *= 1.2;
    if (fertilizer == 'Compost') base *= 0.8;

    return base * area;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header matching CropsPage
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green[400],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Fertilizing',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Crop type", style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration(),
                    value: selectedCrop,
                    hint: Text("select"),
                    onChanged: (value) {
                      setState(() {
                        selectedCrop = value;
                      });
                    },
                    items: crops
                        .map((crop) => DropdownMenuItem(
                              value: crop,
                              child: Text(crop),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 30),
                  Text("Fertilizer type", style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration(),
                    value: selectedFertilizer,
                    hint: const Text("select"),
                    enableFeedback: false,
                    onChanged: (value) {
                      setState(() {
                        selectedFertilizer = value;
                      });
                    },
                    items: fertilizers
                        .map((fertilizer) => DropdownMenuItem(
                              value: fertilizer,
                              child: Text(fertilizer),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 30),
                  Text("Added Area", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: areaController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(),
                  ),
                  SizedBox(height: 40),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            if (selectedCrop != null &&
                                selectedFertilizer != null &&
                                areaController.text.isNotEmpty) {
                              double? area = double.tryParse(areaController.text);
                              if (area != null) {
                                setState(() {
                                  amountToUse = calculateAmount(selectedCrop!, selectedFertilizer!, area);
                                  taskCompleted = true;
                                });
                              }
                            }
                          },
                          child: Text("Generate", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedCrop = null;
                              selectedFertilizer = null;
                              areaController.clear();
                              amountToUse = null;
                              taskCompleted = false;
                            });
                          },
                          child: Text("Refresh", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Text("Amount to use", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: amountToUse != null
                          ? amountToUse!.toStringAsFixed(2)
                          : '',
                    ),
                    decoration: _inputDecoration().copyWith(
                      hintText: "Calculated amount will appear here",
                    ),
                  ),
                  SizedBox(height: 24),
                  if (taskCompleted) Task(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

Widget Task() {
  return Container(
    alignment: Alignment.center,
    child: Column(
      children: [
        Icon(Icons.assignment_turned_in, size: 80, color: Colors.green),
        SizedBox(height: 10),
        Text(
          'Task completed',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    ),
  );
}
