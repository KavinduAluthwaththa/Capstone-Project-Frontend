import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
// import 'package:google_fonts/google_fonts.dart'; // You can use this if you prefer Poppins

// Import your page destinations
import 'package:capsfront/farmer_area/MarketPrice.dart';
import 'package:capsfront/farmer_area/ShopList.dart';
import 'package:capsfront/farmer_area/Crops.dart';
// Add dummy pages or real pages for new buttons
// import 'crop_prediction_page.dart';
// import 'diseases_management_page.dart';
// import 'fertilizer_recommendation_page.dart';


// --- Main App Setup (from your existing code, slightly adapted) ---
// You would typically have this in your main.dart
// For this example, I'm keeping it here to make the file runnable standalone
// if you copy it directly.
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
        primarySwatch: Colors.green, // You can create a custom MaterialColor
        // fontFamily: GoogleFonts.poppins().fontFamily, // Uncomment to use Poppins globally
      ),
      home: FarmerMainPage(email: 'User'), // Pass a name or email
    );
  }
}
// --- End of Main App Setup ---


// Define colors for easy reuse and modification
const Color primaryGreen = Color(0xFFAED581); // Light green for header and buttons
const Color darkGreen = Color(0xFF558B2F);   // Dark green for bottom nav
const Color textOnPrimary = Colors.black87;
const Color textOnDark = Colors.white;
const Color iconRed = Colors.red;
const Color weatherIconColor = Colors.orangeAccent; // Color for the sun part of the icon

class FarmerMainPage extends StatefulWidget {
  final String email; // Or farmerName
  const FarmerMainPage({super.key, required this.email});

  @override
  State<FarmerMainPage> createState() => _FarmerMainPageState();
}

class _FarmerMainPageState extends State<FarmerMainPage> {
  int _selectedIndex = 0; // For BottomNavigationBar

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation or state change based on the selected tab
    if (index == 0) {
      // Already on Home, or navigate to a dedicated Home screen if different
      print("Home tapped");
    } else if (index == 1) {
      print("Com.chat tapped");
      // Navigator.push(context, MaterialPageRoute(builder: (context) => ComChatPage()));
    } else if (index == 2) {
      print("AI chat bot tapped");
      // Navigator.push(context, MaterialPageRoute(builder: (context) => AiChatBotPage()));
    } else if (index == 3) {
      print("My account tapped");
      // Navigator.push(context, MaterialPageRoute(builder: (context) => MyAccountPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            _buildTopHeader(),
            Expanded(
              child: _buildActionButtonsList(),
            ),
            // Optional "Component" text - if it's truly part of the UI
            // _buildComponentAnnotation(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTopHeader() {
    String farmerDisplayName = widget.email; // Using email as the display name as per your existing code

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
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
              // Hamburger Menu Icon
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.menu, color: textOnPrimary, size: 30),
                onPressed: () {
                  print("Menu button pressed");
                  // Scaffold.of(context).openDrawer(); // If you have a drawer
                },
              ),
              // Location
              Row(
                children: [
                  const Icon(Icons.location_on, color: iconRed, size: 28),
                  const SizedBox(width: 5),
                  Text(
                    "Anuradhapura",
                    style: TextStyle(
                        // fontFamily: GoogleFonts.poppins().fontFamily,
                        color: textOnPrimary.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Weather Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
            children: [
              // "Now" and Temperature
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Now",
                    style: TextStyle(
                        // fontFamily: GoogleFonts.poppins().fontFamily,
                        color: textOnPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "26°",
                    style: TextStyle(
                      // fontFamily: GoogleFonts.poppins().fontFamily,
                      color: textOnPrimary.withOpacity(0.95),
                      fontSize: 50, // Adjusted size
                      fontWeight: FontWeight.bold,
                      height: 1.1, // Adjust line height for better visual alignment
                    ),
                  ),
                ],
              ),
              const Spacer(), // Pushes the greeting to the right if needed, or remove if layout is different
            ],
          ),
            const SizedBox(height: 10),
          // Greeting and weather icon
          Row(
            children: [
              // Weather icon (sun behind cloud) - using a Stack for layering
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.cloud_outlined, color: Colors.grey[400], size: 45),
                  Positioned(
                    top: -2, // Adjust to position sun correctly
                    left: -5, // Adjust to position sun correctly
                    child: Icon(Icons.wb_sunny, color: weatherIconColor.withOpacity(0.8), size: 30),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              Expanded( // Use Expanded to prevent overflow if name is long
                child: Text(
                  "Hi <$farmerDisplayName>!",
                  style: const TextStyle(
                      // fontFamily: GoogleFonts.poppins().fontFamily,
                      color: textOnPrimary,
                      fontSize: 18, // Adjusted size
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsList() {
    // Button data: title and onPressed action
    final List<Map<String, dynamic>> buttonsData = [
      {
        "title": "Crops",
        "onPressed": () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CropsPage()));
        }
      },
      {
        "title": "Shop list",
        "onPressed": () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ShopListPage()));
        }
      },
      {
        "title": "Market price",
        "onPressed": () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MarketPriceScreen()));
        }
      },
      {
        "title": "Crop prediction",
        "onPressed": () {
          print("Crop prediction pressed");
          // Navigator.push(context, MaterialPageRoute(builder: (context) => CropPredictionPage()));
        }
      },
      {
        "title": "Diseases management",
        "onPressed": () {
          print("Diseases management pressed");
          // Navigator.push(context, MaterialPageRoute(builder: (context) => DiseasesManagementPage()));
        }
      },
      {
        "title": "Fertilizer recommendation",
        "onPressed": () {
          print("Fertilizer recommendation pressed");
          // Navigator.push(context, MaterialPageRoute(builder: (context) => FertilizerRecommendationPage()));
        }
      },
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      children: buttonsData.map((buttonData) => Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: _buildActionButton(
          title: buttonData["title"],
          onPressed: buttonData["onPressed"],
        ),
      )).toList(),
    );
  }

  Widget _buildActionButton({required String title, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 60, // Adjusted height
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen.withOpacity(0.9), // Using defined primaryGreen
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
          ),
          elevation: 2,
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(
            // fontFamily: GoogleFonts.poppins().fontFamily,
            fontSize: 18, // Adjusted font size
            color: textOnPrimary,
            fontWeight: FontWeight.w500, // Adjusted weight
          ),
        ),
      ),
    );
  }

  // Optional: If the "Component" text is really part of the UI
  Widget _buildComponentAnnotation() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, bottom: 10.0, top: 5.0),
      child: Row(
        children: const [
          Icon(Icons.diamond_outlined, color: Colors.purpleAccent, size: 16),
          SizedBox(width: 4),
          Text(
            "Component",
            style: TextStyle(color: Colors.purpleAccent, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline), // For Com.chat
          activeIcon: Icon(Icons.chat_bubble),
          label: 'Com.chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline), // For AI chat bot
          activeIcon: Icon(Icons.person),
          label: 'AI chat bot',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_outlined),
          activeIcon: Icon(Icons.account_circle),
          label: 'My account',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: textOnDark,
      unselectedItemColor: textOnDark.withOpacity(0.7),
      backgroundColor: darkGreen,
      type: BottomNavigationBarType.fixed, // To show all labels
      onTap: _onItemTapped,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      iconSize: 26,
    );
  }
}
