import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Market Price',
      home: MarketPriceScreen(),
    );
  }
}

class MarketPriceScreen extends StatelessWidget {
  final List<String> crops = ['Rice', 'Wheat', 'Corn'];
  final String selectedCrop = 'Rice';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        backgroundColor: Color(0xFF8ABF6F),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat), label: 'Com.chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy), label: 'AI chat bot'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'My account'),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 50, bottom: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFF8ABF6F),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Center(
              child: Text(
                'Market price',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedCrop,
                  items: crops.map((String crop) {
                    return DropdownMenuItem<String>(
                      value: crop,
                      child: Text(crop),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {},
                ),
                Text('1 kg', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(10),
            height: 200,
            decoration: BoxDecoration(
              color: Color(0xFFE6F5E8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CustomPaint(
              painter: BarChartPainter(),
            ),
          ),
          SizedBox(height: 20),
          Text('Crop 1', style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}

class BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blue;
    final days = 7;
    final barWidth = size.width / (days * 2);
    final barHeights = [0.6, 0.3, 0.3, 0.4, 0.6, 0.7, 0.1];

    for (int i = 0; i < days; i++) {
      double left = i * (barWidth * 2) + barWidth / 2;
      double top = size.height * (1 - barHeights[i]);
      double right = left + barWidth;
      double bottom = size.height;

      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
