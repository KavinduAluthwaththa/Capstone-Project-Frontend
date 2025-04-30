import 'package:flutter/material.dart';


class Fertilizing extends StatefulWidget {
  @override
  _FertilizingState createState() => _FertilizingState();
}

class _FertilizingState extends State<Fertilizing> {
  bool taskCompleted = false;
  String? selectedCrop;
  String? selectedFertilizer;
  TextEditingController quantityController = TextEditingController();

  List<String> crops = ['Wheat', 'Corn', 'Rice'];
  List<String> fertilizers = ['Urea', 'DAP', 'Compost'];



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: Text("Fertilizing",style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Color(0xFFA7DB8D),
      ),
      backgroundColor: Colors.white,


      body: SafeArea(

        child: Column(
          children: [
            Container(


            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Crop type",style: TextStyle(fontWeight: FontWeight.bold),),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration(),
                    value: selectedCrop,
                    hint:  Text("select"),
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
                  Text("Fertilizer type",style: TextStyle(fontWeight: FontWeight.bold),),
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
                  Text("Added quantity",style: TextStyle(fontWeight: FontWeight.bold),),
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(),
                  ),
                  SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding:
                        EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),

                        ),
                      ),
                      onPressed : () {
                        setState(() {
                          taskCompleted = true;
                        });
                      },

                      child:  Text("Save information",style: TextStyle(fontWeight: FontWeight.bold),),
                    ),
                  ),
                  SizedBox(height: 24),
                  if (taskCompleted) Task()



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
    ); }
}

Widget Task() {
  return Container (
      alignment: Alignment.center,
      child: Column(

        children: [
          Icon(Icons.assignment_turned_in,
              size: 80, color: Colors.green),
          SizedBox(height: 10),
          Text(
            'Task completed',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ));}
