import 'package:capsfront/models/cropDisease_model.dart';
import 'package:capsfront/services/crop_disease_service.dart';
import 'package:flutter/material.dart';

class CropDiseasePage extends StatefulWidget {
  final String token;

  const CropDiseasePage({super.key, required this.token});

  @override
  State<CropDiseasePage> createState() => _CropDiseasePageState();
}

class _CropDiseasePageState extends State<CropDiseasePage> {
  List<CropDisease> cropDiseases = [];
  final service = CropDiseaseService();

  // Dummy lists for dropdowns (replace with API calls if needed)
  List<int> cropIds = [1, 2, 3];
  List<int> diseaseIds = [10, 11, 12];

  int? selectedCropId;
  int? selectedDiseaseId;
  TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDiseases();
  }

  Future<void> fetchDiseases() async {
    final data = await service.getAllCropDiseases(widget.token);
    setState(() => cropDiseases = data);
  }

  Future<void> addOrUpdateDisease({CropDisease? existing}) async {
    final isUpdating = existing != null;

    selectedCropId = existing?.cropId;
    selectedDiseaseId = existing?.diseaseId;
    dateController.text = existing?.date ?? "";

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(isUpdating ? "Update Crop Disease" : "Add Crop Disease"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedCropId,
                items: cropIds.map((id) {
                  return DropdownMenuItem(value: id, child: Text("Crop $id"));
                }).toList(),
                onChanged: (val) => selectedCropId = val,
                decoration: const InputDecoration(labelText: "Select Crop ID"),
              ),
              DropdownButtonFormField<int>(
                value: selectedDiseaseId,
                items: diseaseIds.map((id) {
                  return DropdownMenuItem(value: id, child: Text("Disease $id"));
                }).toList(),
                onChanged: (val) => selectedDiseaseId = val,
                decoration: const InputDecoration(labelText: "Select Disease ID"),
              ),
              TextFormField(
                controller: dateController,
                decoration: const InputDecoration(labelText: "Date (YYYY-MM-DD)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final disease = CropDisease(
                  cdid: existing?.cdid,
                  cropId: selectedCropId!,
                  diseaseId: selectedDiseaseId!,
                  date: dateController.text,
                );
                if (isUpdating) {
                  await service.updateCropDisease(disease, widget.token as int, disease.cdid!.toString());
                } else {
                  await service.addCropDisease(disease, widget.token);
                }
                await fetchDiseases();
                Navigator.pop(context);
              },
              child: Text(isUpdating ? "Update" : "Add"),
            )
          ],
        );
      },
    );
  }

  Future<void> deleteDisease(int id) async {
    await service.deleteCropDisease(id, widget.token);
    await fetchDiseases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crop Disease Records")),
      body: ListView.builder(
        itemCount: cropDiseases.length,
        itemBuilder: (context, index) {
          final item = cropDiseases[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text("Crop: ${item.cropName ?? item.cropId}, Disease: ${item.diseaseName ?? item.diseaseId}"),
              subtitle: Text("Date: ${item.date}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => addOrUpdateDisease(existing: item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteDisease(item.cdid!),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addOrUpdateDisease(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
