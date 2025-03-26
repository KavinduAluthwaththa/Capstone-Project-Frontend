import 'package:capsfront/models/crop_model.dart';
import 'package:capsfront/shared/crop_services.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FarmerCropsPage(),
    );
  }
}

class FarmerCropsPage extends StatefulWidget {
  const FarmerCropsPage({super.key});

  @override
  _FarmerCropsPageState createState() => _FarmerCropsPageState();
}

class _FarmerCropsPageState extends State<FarmerCropsPage> {
  final CropService _cropService = CropService();
  List<Crop> _crops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCrops();
  }

  Future<void> _fetchCrops() async {
    try {
      List<Crop> crops = await _cropService.getCrops();
      setState(() {
        _crops = crops;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addCrop() async {
    TextEditingController nameController = TextEditingController();
    TextEditingController seasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New Crop"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Crop Name")),
              TextField(controller: seasonController, decoration: InputDecoration(labelText: "Planting Season")),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Crop newCrop = Crop(cropName: nameController.text, plantingSeason: seasonController.text, farmerId: '');
                bool success = await _cropService.addCrop(newCrop);
                if (success) _fetchCrops();
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCrop(int cropId) async {
    bool success = await _cropService.deleteCrop(cropId);
    if (success) _fetchCrops();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Crops"), actions: [
        IconButton(icon: Icon(Icons.add), onPressed: _addCrop),
      ]),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _crops.isEmpty
              ? Center(child: Text("No crops added yet"))
              : ListView.builder(
                  itemCount: _crops.length,
                  itemBuilder: (context, index) {
                    final crop = _crops[index];
                    return ListTile(
                      title: Text(crop.cropName),
                      subtitle: Text("Season: ${crop.plantingSeason}"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCrop(crop.id!),
                      ),
                    );
                  },
                ),
    );
  }
}
