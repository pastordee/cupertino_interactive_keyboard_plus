import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cupertino_interactive_keyboard_example/catalog.dart';
import 'package:cupertino_interactive_keyboard_example/input_accessory.dart';
import 'package:cupertino_interactive_keyboard_example/nested_navigation.dart';
import 'package:cupertino_interactive_keyboard_example/reversed_scroll_view.dart';
import 'package:cupertino_interactive_keyboard_example/simple_scroll_view.dart';

/// Entry point for the Cupertino Interactive Keyboard example application.
/// 
/// This app demonstrates the interactive keyboard dismissal functionality
/// provided by the cupertino_interactive_keyboard plugin with various
/// usage scenarios and configurations.
void main() {
  runApp(const CupertinoInteractiveKeyboardExample());
}

/// The main application widget that showcases cupertino_interactive_keyboard functionality.
/// 
/// This app provides a comprehensive demonstration of interactive keyboard dismissal
/// features on iOS, including:
/// - Basic scroll view integration
/// - Input accessory view support
/// - Nested navigation scenarios
/// - Reversed scroll view handling
/// 
/// The app uses a consistent Material Design theme with proper navigation
/// and accessibility features.
class CupertinoInteractiveKeyboardExample extends StatelessWidget {
  const CupertinoInteractiveKeyboardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cupertino Interactive Keyboard Example',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: _buildRoutes(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.2,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  /// Builds the light theme for the application.
  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  /// Builds the dark theme for the application.
  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  /// Builds the route configuration for the application.
  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/': (context) => const Catalog(),
      '/simple_scroll_view': (context) => const SimpleScrollView(),
      '/input_accessory': (context) => const InputAccessory(),
      '/nested_navigation': (context) => const NestedNavigation(),
      '/reversed_scroll_view': (context) => const ReversedScrollView(),
    };
  }
}
