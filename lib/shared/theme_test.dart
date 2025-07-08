// Test file to verify dark mode implementation
// This file can be deleted after testing

import 'package:flutter/material.dart';
import 'package:capsfront/services/theme_service.dart';
import 'package:provider/provider.dart';

class ThemeTestPage extends StatelessWidget {
  const ThemeTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theme Test')),
      body: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Current Theme: ${themeService.isDarkMode ? 'Dark' : 'Light'}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    themeService.toggleTheme();
                  },
                  child: Text(
                    'Toggle to ${themeService.isDarkMode ? 'Light' : 'Dark'} Mode',
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'This is a sample card to test the theme colors.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
