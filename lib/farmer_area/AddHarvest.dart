import 'package:flutter/material.dart';

// Color Palette - Reusing from AddRequest
const Color appBackgroundColor = Colors.white;
const Color topBarColor = Color(0xFFAED581);
const Color formCardBackgroundColor = Color(0xFFE7F0E2);
const Color textFieldFillColor = Color(0xFFF5F5F5);
const Color textFieldBorderColor = Color(0xFFDCDCDC);
const Color postButtonColor = Color(0xFF67A36F); // Same green as request button
const Color postButtonTextColor = Colors.white;
const Color bottomNavBarColor = Color(0xFF5B8C5A);
const Color primaryTextColor = Colors.black;
const Color labelTextColor = Colors.black87;
const Color bottomNavIconSelectedColor = Colors.white;
const Color bottomNavIconUnselectedColor = Color(0xFF3D533D);


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
      title: 'Add Harvest Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      home: const AddHarvestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AddHarvestScreen extends StatefulWidget {
  const AddHarvestScreen({super.key});

  @override
  State<AddHarvestScreen> createState() => _AddHarvestScreenState();
}

class _AddHarvestScreenState extends State<AddHarvestScreen> {
  int _selectedIndex = 0; // Default to Home or as appropriate

  // Text editing controllers for the form fields
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final _cropController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _cropController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Add navigation logic here if needed
    });
  }

  void _submitHarvest() {
    // Handle the harvest submission logic here
    print('Name: ${_nameController.text}');
    print('Location: ${_locationController.text}');
    print('Contact: ${_contactController.text}');
    print('Crop: ${_cropController.text}');
    print('Amount: ${_amountController.text}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Harvest Posted!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
              child: Column(
                children: [
                  _buildUserInfoFormCard(),
                  const SizedBox(height: 20),
                  _buildHarvestDetailsFormCard(), // Renamed for clarity
                  const SizedBox(height: 25),
                  _buildPostButton(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 20,
        left: 10,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: topBarColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: primaryTextColor, size: 28),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(width: 10),
          const Text(
            "Add Harvest", // Changed Title
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: formCardBackgroundColor,
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
        children: children,
      ),
    );
  }

  Widget _buildTextFieldWithLabel({
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: labelTextColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: primaryTextColor, fontSize: 16),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: textFieldFillColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: textFieldBorderColor, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: textFieldBorderColor, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoFormCard() {
    return _buildFormCard(
      children: [
        _buildTextFieldWithLabel(label: "Name :", controller: _nameController),
        _buildTextFieldWithLabel(label: "Location :", controller: _locationController),
        _buildTextFieldWithLabel(label: "Contact :", controller: _contactController, keyboardType: TextInputType.phone),
      ],
    );
  }

  Widget _buildHarvestDetailsFormCard() { // Renamed method
    return _buildFormCard(
      children: [
        const Text(
          "Harvest", // Changed section title
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 10),
        _buildTextFieldWithLabel(label: "Crop :", controller: _cropController),
        _buildTextFieldWithLabel(label: "Amount :", controller: _amountController, hintText: "e.g., 500 kg or 20 units"),
      ],
    );
  }

  Widget _buildPostButton() { // Renamed method
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitHarvest,
        style: ElevatedButton.styleFrom(
          backgroundColor: postButtonColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: const Text(
          "Post", // Changed button text
          style: TextStyle(
            color: postButtonTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: bottomNavBarColor,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.cloud_outlined),
          label: 'Com.chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.support_agent_outlined),
          label: 'AI chat bot',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'My account',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: bottomNavIconSelectedColor,
      unselectedItemColor: bottomNavIconUnselectedColor,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
    );
  }
}
