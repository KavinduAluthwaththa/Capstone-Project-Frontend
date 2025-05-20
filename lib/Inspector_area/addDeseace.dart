import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddDiseasePage extends StatefulWidget {
  const AddDiseasePage({super.key});

  @override
  State<AddDiseasePage> createState() => _AddDiseasePageState();
}

class _AddDiseasePageState extends State<AddDiseasePage> {
  File? _imageFile;
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveInformation() {
    final description = _descriptionController.text;
    if (_imageFile != null && description.isNotEmpty) {
      // Save logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Information saved")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload a photo and add a description")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF91C16C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add Decease",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        toolbarHeight: 100,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload, size: 40),
                            Text("Upload photo"),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Add description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveInformation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF65A830),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text("Save information"),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   selectedItemColor: Colors.white,
      //   unselectedItemColor: Colors.white70,
      //   backgroundColor: const Color(0xFF2B4C1D),
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      //     BottomNavigationBarItem(icon: Icon(Icons.forum), label: "Com.chat"),
      //     BottomNavigationBarItem(icon: Icon(Icons.android), label: "AI chat bot"),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: "My account"),
      //   ],
      //   type: BottomNavigationBarType.fixed,
      // ),
    );
  }
}
