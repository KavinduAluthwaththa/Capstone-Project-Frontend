import 'package:flutter/material.dart';



class DailyAnalysisScreen extends StatelessWidget {
  const DailyAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.lightGreen[700],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.arrow_back),
                  SizedBox(width: 16),
                  Text(
                    'Daily analysis',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InfoCard(value: '25°', label: 'Temperature'),
                InfoCard(value: '41%', label: 'Humidity'),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen[300],
                padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 16),
              ),
              onPressed: () {},
              child: const Text(
                'Fertilizing',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            const SizedBox(height: 50),
            const Text(
              'Raining prediction',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            RainForecast(),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String value;
  final String label;

  const InfoCard({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.lightGreen[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(label),
        ],
      ),
    );
  }
}

class RainForecast extends StatelessWidget {
  const RainForecast({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'H', 'F', 'S', 'S'];
    final percentages = ['70%', '80%', '90%', '80%', '60%', '20%', '0%'];
    final icons = [
      Icons.cloud,
      Icons.cloud,
      Icons.cloud,
      Icons.cloud,
      Icons.cloud,
      Icons.cloud,
      Icons.cloud,
      Icons.wb_sunny
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          return Column(
            children: [
              Text(days[index]),
              const SizedBox(height: 4),
              Icon(icons[index], color: Colors.blue),
              const SizedBox(height: 4),
              Text(percentages[index]),
            ],
          );
        }),
      ),
    );
  }
}
