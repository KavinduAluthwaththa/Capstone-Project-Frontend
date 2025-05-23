import 'package:capsfront/shared/DiseasesM.dart';
import 'package:capsfront/shared/Fertilizing.dart';
import 'package:flutter/material.dart';
import 'package:capsfront/farmer_area/DailyAnalysis.dart';

class CropsPage extends StatefulWidget {
  const CropsPage({super.key});

  @override
  _CropsPageState createState() => _CropsPageState();
}

class _CropsPageState extends State<CropsPage> {
  final TextEditingController _cropController = TextEditingController();

  Map<String, double> dataMap = {
    "crop 1": 1,
    "crop 2": 1,
    "crop 3": 1,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "Crops",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.green[400],
        centerTitle: true,
        toolbarHeight: 100,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.all(15),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  navButton("Daily analysis"),
                  navButton("Crop prdiction"),
                  navButton("Disease management"),
                  navButton("Fertilizer recomendation"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget navButton(String title) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD9F2D9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(5),
      ),
      onPressed: () {
        if (title == "Daily analysis") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DailyAnalysisScreen()),
          );

        } //else if (title == 'Crop prediction') {
              //Navigator.push(
                //context,
                //MaterialPageRoute(),
              //);} 
          else if (title == 'Disease management') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DiseaseM()),
              );

        } else if (title == 'Fertilizer recomendation') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Fertilizing()),
          );
        }
      },
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
