// lib/FarmerProfile.dart

import 'package:flutter/material.dart';

// Troubleshooting steps for "Connection closed before full header was received" error:
// 1. Restart the Flutter development environment (VS Code, Android Studio, etc.).
// 2. Ensure that no other processes are using the same port as the Flutter app.
// 3. Check your internet connection.
// 4. Try running `flutter clean` and then `flutter run` again.
// 5. Update Flutter to the latest version.

// Color Palette - It's good practice to define these at the top or in a separate theme file
const Color appBackgroundColor = Colors.white; // Dark background for the overall app screen
const Color topBarColor = Color(0xFFAED581); // Light green for the top bar
const Color mainCardBackgroundColor = Color(0xFFDCEBCB); // Main green for info and harvest list bg
const Color harvestItemBackgroundColor = Color(0xFFEFF3ED); // Very light bg for individual harvest items
const Color bottomNavBarColor = Color(0xFF5B8C5A); // Darker green for bottom nav
const Color primaryTextColor = Colors.black;
const Color secondaryTextColor = Colors.black54; // For subtitles like FRM ID, kg, price
const Color bottomNavIconSelectedColor = Colors.white;
const Color bottomNavIconUnselectedColor = Color(0xFF3D533D); // Dark, desaturated green/black for unselected icons and text

// If this is the main entry point of your app, you can keep MyApp here.
// Otherwise, you might just export FarmerProfileScreen and use it in your main.dart's MaterialApp.
// For this example, I'll include MyApp to make it runnable directly.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmer Profile Demo',
      theme: ThemeData(
        primarySwatch: Colors.green, // This sets a base color scheme
        fontFamily: 'Roboto', // A common, clean font
        // You can further customize your theme here if needed
      ),
      home: const FarmerProfileScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  int _selectedIndex = 0; // Assuming 'My account' might be the active tab initially or some other logic

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Add navigation logic here if needed, e.g.,
      // if (index == 0) Navigator.pushNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          "Farmer Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: primaryTextColor,
          ),
        ),
        backgroundColor: Colors.green[400], // Match ShopListPage
        centerTitle: true,
        toolbarHeight: 100, // Custom height
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        iconTheme: const IconThemeData(color: primaryTextColor),
      ),
      body: Column(
        children: [
          // Remove _buildTopBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
              child: Column(
                children: [
                  _buildFarmerInfoCardContent(),
                  const SizedBox(height: 20),
                  _buildAvailableHarvestsSectionContent(),
                ],
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildFarmerInfoCardContent() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: mainCardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 28, color: Colors.white),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Robert Anderson",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "FRM-2025-0123",
                    style: TextStyle(color: secondaryTextColor, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: primaryTextColor, size: 24),
              const SizedBox(width: 12),
              Text(
                "Anuradhapuraya, Sri Lanka",
                style: TextStyle(color: primaryTextColor, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.phone_outlined, color: primaryTextColor, size: 24),
              const SizedBox(width: 12),
              Text(
                "077 1234567",
                style: TextStyle(color: primaryTextColor, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableHarvestsSectionContent() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: mainCardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Available Harvests",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 15),
          // List of harvest items - in a real app, this would be generated from data
          _buildHarvestItem(
            "Rice",
            "50 kg",
            "LKR 5000",
            "assets/plant.png", // Using profile image as a placeholder
          ),
          const SizedBox(height: 10),
          _buildHarvestItem(
            "Corn",
            "30 kg",
            "LKR 3000",
            "assets/plant.png", // Using profile image as a placeholder
          ),
          const SizedBox(height: 10),
          _buildHarvestItem(
            "Wheat",
            "20 kg",
            "LKR 2000",
            "assets/plant.png", // Using profile image as a placeholder
          ),
        ],
      ),
    );
  }

  Widget _buildHarvestItem(String title, String quantity, String price, String imagePath) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: harvestItemBackgroundColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  quantity,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            price,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildBottomNavigationBar() {
  //   return BottomNavigationBar(
  //     items: const <BottomNavigationBarItem>[
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.home),
  //         label: 'Home',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.cloud),
  //         label: 'Com.chat',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.person),
  //         label: 'AI chat bot',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.person),
  //         label: 'My account',
  //       ),
  //     ],
  //     currentIndex: _selectedIndex,
  //     selectedItemColor: bottomNavIconSelectedColor,
  //     unselectedItemColor: bottomNavIconUnselectedColor,
  //     onTap: _onItemTapped,
  //     backgroundColor: bottomNavBarColor,
  //     type: BottomNavigationBarType.fixed,
  //   );
  // }
}
