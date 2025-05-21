import 'package:capsfront/Inspector_area/addDeseace.dart';
import 'package:capsfront/Inspector_area/answerQuestion.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: InspectorMainPage(email: 'example@example.com'),
    );
  }
} 

class InspectorMainPage extends StatefulWidget {
  final String email;
  const InspectorMainPage({super.key, required this.email});

  @override
  State<InspectorMainPage> createState() => _InspectorMainPageState();
}

class _InspectorMainPageState extends State<InspectorMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: BottomNavigationBar(
      //   selectedItemColor: Colors.black,
      //   unselectedItemColor: Colors.black54,
      //   backgroundColor: const Color(0xFF8ABF6F),
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      //     BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Com.chat'),
      //     BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'AI chat bot'),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My account'),
      //   ],
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 200,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green[400],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Now', style: GoogleFonts.poppins(fontSize: 20)),
                          const SizedBox(height: 5),
                          Text('26°', style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          const Icon(Icons.cloud, color: Colors.white),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_pin, color: Colors.red),
                          Text('Anuradhapura', style: GoogleFonts.poppins(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      children: [
                        Text('Hi, ${widget.email}!', style: GoogleFonts.poppins(fontSize: 20)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    buildButton('Add Diseases'),
                    const SizedBox(height: 50),
                    buildButton('Answer Questions'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        height: 70,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            if (text == 'Add Diseases') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddDiseasePage()),
              );
            } else if (text == 'Answer Questions') {
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(content: Text('Order Request button clicked')),
              // );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnswerQuestionsPage()),
              );
            }
          },
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 20, color: Colors.green.shade900, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}