import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';


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
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.lightGreen[700],
                // color: Color(0xFFA8D08D),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.arrow_back, size: 28),
                  SizedBox(width: 16),
                  Text(
                    'Crops',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cropController,
                      decoration: InputDecoration(
                        hintText: '+ Add crop',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      // Add crop logic here
                    },
                    child: Text("Add"),
                  ),
                ],
              ),
            ),

            SizedBox(height: 5,),
            PieChart(
              dataMap: dataMap,
              chartType: ChartType.disc,
              chartRadius: 120,
              legendOptions: LegendOptions(showLegends: true),
              chartValuesOptions: ChartValuesOptions(showChartValues: false),
            ),


            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.all(15),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  navButton("Daily analysis"),
                  navButton("Crop prdiction"),
                  navButton("Diseaces management"),
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
        backgroundColor: Color(0xFFD9F2D9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(5),
      ),
      onPressed: () {

      },
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
