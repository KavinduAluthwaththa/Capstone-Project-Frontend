import 'package:flutter/material.dart';
import 'package:capsfront/shared/Splash.dart';
import 'package:capsfront/shared/settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const SettingsPage(), // Set Splashscreen as the initial page
    );
  }
}
