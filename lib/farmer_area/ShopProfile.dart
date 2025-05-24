// lib/ShopProfile.dart

import 'package:flutter/material.dart';

// Color Palette - Reusing from the previous style
const Color appBackgroundColor = Colors.white;
const Color topBarColor = Color(0xFFAED581);
const Color mainCardBackgroundColor = Color(0xFFDCEBCB); // Very light green for main card backgrounds
const Color orderItemBackgroundColor = Color(0xFFEFF3ED); // Even lighter for individual order items
const Color bottomNavBarColor = Color(0xFF5B8C5A);
const Color primaryTextColor = Colors.black;
const Color secondaryTextColor = Colors.black54;
const Color tertiaryTextColor = Colors.black38; // For "ID:", "Quantity:", "Deadline:" labels
const Color bottomNavIconSelectedColor = Colors.white;
const Color bottomNavIconUnselectedColor = Color(0xFF3D533D);
const Color pendingStatusColor = Color(0xFFFFEEA2); // Light yellow for pending badge

// If this is the main entry point of your app, you can keep MyApp here.
// For this example, I'll include MyApp to make it runnable directly.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop Profile Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      home: const ShopProfileScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ShopProfileScreen extends StatefulWidget {
  const ShopProfileScreen({super.key});

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  int _selectedIndex = 3; // Assuming 'My account' might be the active tab for a profile page

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Add navigation logic here if needed
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
          "Shop Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: primaryTextColor,
          ),
        ),
        backgroundColor: Colors.green[400], // Match ShopListPage
        centerTitle: true,
        toolbarHeight: 100,
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
                  _buildShopInfoCardContent(),
                  const SizedBox(height: 20),
                  _buildOrderRequestsSectionContent(),
                ],
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildShopInfoCardContent() {
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
              const Icon(Icons.store_mall_directory_outlined, size: 32, color: primaryTextColor),
              const SizedBox(width: 15),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Green Valley Agro Supply",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "SHOP-2025-0456",
                    style: TextStyle(color: secondaryTextColor, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildInfoRow(Icons.location_on_outlined, "Anuradhapuraya, Sri Lanka"),
          _buildInfoRow(Icons.phone_outlined, "077 1234567"),
          _buildInfoRow(Icons.access_time_outlined, "Mon-Sat: 8:00 AM - 6:00 PM"),
          _buildInfoRow(Icons.person_outline, "Robert Anderson"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: primaryTextColor, size: 22),
          const SizedBox(width: 12),
          Expanded( // Added Expanded to prevent overflow if text is long
            child: Text(
              text,
              style: const TextStyle(color: primaryTextColor, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderRequestsSectionContent() {
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
            "Order Requests",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 15),
          _buildOrderRequestItem(
            productName: "Organic Tomatoes",
            id: "REQ-2505",
            quantity: "500 kg",
            deadline: "June 15, 2025",
          ),
          _buildOrderRequestItem(
            productName: "Fresh Lettuce",
            id: "REQ-2505", // Assuming ID can be same for different products if it's a batch request ID
            quantity: "300 kg",
            deadline: "June 18, 2025",
          ),
        ],
      ),
    );
  }

  Widget _buildOrderRequestItem({
    required String productName,
    required String id,
    required String quantity,
    required String deadline,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: orderItemBackgroundColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: primaryTextColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: pendingStatusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Pending",
                    style: TextStyle(
                      color: Colors.black87, // Darker text for readability on yellow
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "ID: $id",
              style: const TextStyle(color: secondaryTextColor, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  "Quantity: ",
                  style: TextStyle(color: tertiaryTextColor, fontSize: 14),
                ),
                Text(
                  quantity,
                  style: const TextStyle(
                      color: primaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text(
                  "Deadline: ",
                  style: TextStyle(color: tertiaryTextColor, fontSize: 14),
                ),
                Text(
                  deadline,
                  style: const TextStyle(
                      color: primaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildBottomNavigationBar() {
  //   return BottomNavigationBar(
  //     backgroundColor: bottomNavBarColor,
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
  //     type: BottomNavigationBarType.fixed,
  //     showUnselectedLabels: true,
  //     selectedFontSize: 12,
  //     unselectedFontSize: 12,
  //     selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
  //     unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
  //   );
  // }
}
