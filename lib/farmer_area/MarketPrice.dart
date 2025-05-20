import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Market Price',
      home: MarketPriceScreen(),
    );
  }
}

class MarketPriceScreen extends StatefulWidget {
  const MarketPriceScreen({super.key});
  @override
  _MarketPriceScreenState createState() => _MarketPriceScreenState();
}

class _MarketPriceScreenState extends State<MarketPriceScreen> {
  final List<String> crops = ['Rice', 'Wheat', 'Corn'];
  String selectedCrop = 'Rice';

  final Map<String, List<double>> cropData = {
    'Rice': [0.6, 0.3, 0.3, 0.5, 0.55, 0.7, 0.05],
    'Wheat': [0.2, 0.4, 0.35, 0.3, 0.5, 0.3, 0.1],
    'Corn': [0.1, 0.5, 0.6, 0.45, 0.65, 0.75, 0.6],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFA1D58B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Market price",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        backgroundColor: Color(0xFF8ABF6F),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Com.chat'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'AI chat bot'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My account'),
        ],
      ),
      body: Column(
        children: [
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
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedCrop = newValue;
                      });
                    }
                  },
                ),
                Text('1 kg', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(20),
            height: 220,
            decoration: BoxDecoration(
              color: Color(0xFFE6F5E8),
              borderRadius: BorderRadius.circular(30),
            ),
            child: CustomPaint(
              painter: BarChartPainter(cropData[selectedCrop]!),
              size: Size(double.infinity, 150),
            ),
          ),
          SizedBox(height: 20),
          Text(selectedCrop, style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}

class BarChartPainter extends CustomPainter {
  final List<double> barHeights;
  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  BarChartPainter(this.barHeights);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint barPaint = Paint()..color = Colors.blue;
    final Paint linePaint = Paint()
      ..color = Colors.blue.shade100
      ..strokeWidth = 1;

    final double barWidth = size.width / (barHeights.length * 2);
    final double chartHeight = size.height - 20;

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw horizontal lines and Y-axis labels
    for (int i = 0; i <= 4; i++) {
      double y = chartHeight * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);

      textPainter.text = TextSpan(
        text: '${(100 - i * 25)}%',
        style: TextStyle(fontSize: 10, color: Colors.blue.shade300),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-35, y - 6));
    }

    // Draw bars and day labels
    for (int i = 0; i < barHeights.length; i++) {
      double left = i * (barWidth * 2) + barWidth / 2;
      double top = chartHeight * (1 - barHeights[i]);
      double right = left + barWidth;
      double bottom = chartHeight;

      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), barPaint);

      textPainter.text = TextSpan(
        text: days[i],
        style: TextStyle(fontSize: 10, color: Colors.black),
      );
      textPainter.layout();
      double xCenter = left + (barWidth - textPainter.width) / 2;
      textPainter.paint(canvas, Offset(xCenter, bottom + 5));
    }
  }

  @override
  bool shouldRepaint(covariant BarChartPainter oldDelegate) {
    return oldDelegate.barHeights != barHeights;
  }
}
