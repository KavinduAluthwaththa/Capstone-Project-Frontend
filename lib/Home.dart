import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome Back, User!",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF4A6B3E)),
            ),
            const SizedBox(height: 10),

            const SizedBox(height: 30),

            // Quick Access Cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Two columns
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildFeatureCard(Icons.chat, "Chat", Colors.green, context),
                  _buildFeatureCard(Icons.school, "Courses", Colors.blue, context),
                  _buildFeatureCard(Icons.chat_bubble_outline, "Chatbot", Colors.orange, context),
                  _buildFeatureCard(Icons.person, "My Account", Colors.purple, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, Color color, BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
