import 'package:cupertino_interactive_keyboard_plus/cupertino_interactive_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// An example demonstrating nested navigation scenarios with interactive keyboard dismissal.
/// 
/// This screen showcases how the CupertinoInteractiveKeyboard widget behaves
/// when navigating between different screens in a navigation stack. It demonstrates
/// that the interactive keyboard functionality is tied to specific routes and
/// doesn't interfere with normal navigation patterns.
/// 
/// ## Key Features Demonstrated:
/// - Route-aware keyboard management
/// - Navigation stack behavior
/// - Conditional interactive keyboard functionality
/// - Multi-screen app integration
/// 
/// ## How It Works:
/// The first screen has the CupertinoInteractiveKeyboard wrapper, enabling
/// interactive dismissal. The second screen deliberately omits this wrapper
/// to show the difference in behavior and demonstrate route-specific functionality.
class NestedNavigation extends StatelessWidget {
  const NestedNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nested Navigation'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () => _navigateToSecondScreen(context),
            child: const Text('Next'),
          ),
          IconButton(
            onPressed: () => _showInfoDialog(context),
            icon: const Icon(Icons.info_outline),
            tooltip: 'Show example information',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusBanner(context, hasInteractiveKeyboard: true),
          Expanded(
            child: CupertinoInteractiveKeyboard(
              child: _buildScreenContent(
                context,
                title: 'First Screen (Interactive)',
                description: 'This screen has CupertinoInteractiveKeyboard enabled. '
                           'You can drag down to dismiss the keyboard interactively.',
                cardColor: Theme.of(context).colorScheme.primaryContainer,
                textColor: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Navigates to the second screen without interactive keyboard functionality.
  void _navigateToSecondScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NestedNavigationSecond(),
      ),
    );
  }

  /// Shows an information dialog explaining the example.
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nested Navigation Example'),
        content: const Text(
          'This example demonstrates how CupertinoInteractiveKeyboard works '
          'with navigation stacks.\n\n'
          'The first screen (this one) has interactive keyboard dismissal enabled. '
          'The second screen deliberately omits this functionality to show the '
          'difference in behavior.\n\n'
          'This pattern allows you to enable interactive keyboard dismissal '
          'only on specific screens where it makes sense, without affecting '
          'the entire app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

/// The second screen in the nested navigation example.
/// 
/// This screen intentionally does NOT use CupertinoInteractiveKeyboard
/// to demonstrate the difference in behavior between screens with and
/// without interactive keyboard dismissal functionality.
class NestedNavigationSecond extends StatelessWidget {
  const NestedNavigationSecond({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Screen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () => _showInfoDialog(context),
            icon: const Icon(Icons.info_outline),
            tooltip: 'Show example information',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusBanner(context, hasInteractiveKeyboard: false),
          Expanded(
            child: _buildScreenContent(
              context,
              title: 'Second Screen (Standard)',
              description: 'This screen does NOT have CupertinoInteractiveKeyboard. '
                         'The keyboard will behave normally without interactive dismissal.',
              cardColor: Theme.of(context).colorScheme.errorContainer,
              textColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }

  /// Shows an information dialog explaining this screen.
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Second Screen (No Interactive Keyboard)'),
        content: const Text(
          'This screen demonstrates normal keyboard behavior without the '
          'CupertinoInteractiveKeyboard wrapper.\n\n'
          'Notice that:\n'
          '• The keyboard cannot be dismissed by dragging\n'
          '• Normal keyboard dismissal methods still work\n'
          '• Navigation between screens works normally\n\n'
          'This shows how you can selectively enable interactive keyboard '
          'dismissal on specific screens in your app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

/// Builds the status banner indicating whether interactive keyboard is enabled.
Widget _buildStatusBanner(BuildContext context, {required bool hasInteractiveKeyboard}) {
  final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
  
  Color backgroundColor;
  Color textColor;
  IconData icon;
  String message;
  
  if (!isIOS) {
    backgroundColor = Theme.of(context).colorScheme.errorContainer;
    textColor = Theme.of(context).colorScheme.onErrorContainer;
    icon = Icons.info;
    message = 'Interactive keyboard dismissal only works on iOS devices';
  } else if (hasInteractiveKeyboard) {
    backgroundColor = Theme.of(context).colorScheme.primaryContainer;
    textColor = Theme.of(context).colorScheme.onPrimaryContainer;
    icon = Icons.touch_app;
    message = 'Interactive keyboard dismissal is ENABLED - drag down to dismiss';
  } else {
    backgroundColor = Theme.of(context).colorScheme.errorContainer;
    textColor = Theme.of(context).colorScheme.onErrorContainer;
    icon = Icons.block;
    message = 'Interactive keyboard dismissal is DISABLED - normal keyboard behavior';
  }

  return Container(
    width: double.infinity,
    color: backgroundColor,
    padding: const EdgeInsets.all(12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: textColor, size: 20),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}

/// Builds the main content for a screen with form fields and explanatory text.
Widget _buildScreenContent(
  BuildContext context, {
  required String title,
  required String description,
  required Color cardColor,
  required Color textColor,
}) {
  return CustomScrollView(
    slivers: [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.keyboard,
                        size: 48,
                        color: textColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Interactive Dismissal',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const TextField(
                        decoration: InputDecoration(
                          hintText: 'Tap here and try to drag down to dismiss...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const TextField(
                        decoration: InputDecoration(
                          hintText: 'Another text field to test with...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
