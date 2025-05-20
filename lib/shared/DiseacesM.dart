import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DiseaseM extends StatefulWidget {
  const DiseaseM({super.key});

  @override
  _DiseaseMState createState() => _DiseaseMState();
}

class _DiseaseMState extends State<DiseaseM> {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  height: 120,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFA7DB8D),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back, size: 28),
                      const SizedBox(width: 16),
                      const Text(
                        'Diseaces Management',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Upload Photo (Clickable)
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _image != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _image!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                        : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload, size: 30),
                          SizedBox(height: 8),
                          Text('Upload photo', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30,),

                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Text here',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding:  EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child:  Text('Upload',style: TextStyle(color: Colors.black),),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Comments Button
                Container(
                  margin:  EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  padding:  EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:  ElevatedButton(

                    onPressed: () {  },

                    child: Text(
                      'Comments',
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                    ),
                  ),
                ),


                SizedBox(height: 10),

                // Common diseases label
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Common diseaces',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                // Diseases List
                DiseaseItem(name: 'Anthracnose'),
                DiseaseItem(name: 'Rice Blast'),
              ],
            ),
          ),
        ));
  }
}

class DiseaseItem extends StatelessWidget {
  final String name;

  const DiseaseItem({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFFCDEFC1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: Text(name)),
          ElevatedButton(
            onPressed: () {  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                  children: [
                    Text("Read more"),
                    Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black)
                  ]),

            ),
          )
        ],
      ),
    );
  }
}