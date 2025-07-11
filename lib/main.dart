import 'package:capsfront/shared/Splash.dart';
import 'package:flutter/material.dart';
import 'package:capsfront/shop_owner_area/ShopMainPage.dart';
import 'package:capsfront/farmer_area/FarmerMainPage.dart';
import 'package:capsfront/shared/Chatbot.dart';
import 'package:capsfront/shared/ProfilePage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:capsfront/services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");
    runApp(
      ChangeNotifierProvider(
        create: (context) => ThemeService(),
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Error loading .env file: $e');
    runApp(
      ChangeNotifierProvider(
        create: (context) => ThemeService(),
        child: const MyApp(),
      ),
    );
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeService.lightTheme,
          darkTheme: ThemeService.darkTheme,
          themeMode: themeService.currentTheme,
          home: const Splashscreen(),
        );
      },
    );
  }
}

class BottomNavigationHandler extends StatefulWidget {
  const BottomNavigationHandler({super.key});
  @override
  State<BottomNavigationHandler> createState() =>
      _BottomNavigationHandlerState();
}

class _BottomNavigationHandlerState extends State<BottomNavigationHandler> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    ShopOwnerMainPage(),
    FarmerMainPage(),
    ChatbotPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.agriculture), label: 'Farm'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'Chatbot'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
