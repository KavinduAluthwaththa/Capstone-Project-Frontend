import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:capsfront/accounts/login.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to LoginPage after a delay of 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade900, Colors.white10],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              _buildIcon(),
              const SizedBox(height: 20),
              const Text(
                "Crop Planning",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              _buildLoading(),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: const Icon(
        Icons.agriculture,
        size: 90,
        color: Colors.white,
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 50),
      child: Lottie.network(
        'https://lottie.host/9f1a777d-fa08-4d3b-8c88-9e510ee525be/r1E9fn5G5E.json',
      ),
    );
  }
}