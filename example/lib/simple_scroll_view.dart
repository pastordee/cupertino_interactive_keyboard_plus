import 'package:cupertino_interactive_keyboard/cupertino_interactive_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// A simple example demonstrating basic interactive keyboard dismissal functionality.
/// 
/// This screen shows the fundamental use case of the CupertinoInteractiveKeyboard widget:
/// wrapping a scrollable widget containing text input fields to enable interactive
/// keyboard dismissal on iOS.
/// 
/// ## Key Features Demonstrated:
/// - Basic CupertinoInteractiveKeyboard integration
/// - ListView with text input fields
/// - Interactive keyboard dismissal through pan gestures
/// - Proper handling of multiline text input
/// 
/// ## How It Works:
/// On iOS, users can drag down on the text field to interactively dismiss the keyboard,
/// providing a native-feeling experience similar to other iOS apps.
class SimpleScrollView extends StatefulWidget {
  const SimpleScrollView({super.key});

  @override
  State<SimpleScrollView> createState() => _SimpleScrollViewState();
}

class _SimpleScrollViewState extends State<SimpleScrollView> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    // Initialize controllers and focus nodes for multiple text fields
    for (int i = 0; i < 5; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
    
    // Set initial content for the first field
    _controllers[0].text = _kSampleText;
  }

  @override
  void dispose() {
    // Dispose of all controllers and focus nodes
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Scroll View'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _showInfoDialog,
            icon: const Icon(Icons.info_outline),
            tooltip: 'Show example information',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildInstructionBanner(context),
          Expanded(
            child: CupertinoInteractiveKeyboard(
              child: ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: _buildScrollViewItems().length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) => _buildScrollViewItems()[index],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the instruction banner shown at the top of the screen.
  Widget _buildInstructionBanner(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.errorContainer,
        padding: const EdgeInsets.all(12),
        child: Text(
          'Interactive keyboard dismissal only works on iOS devices',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.all(12),
      child: Text(
        'Tap a text field, then drag down to dismiss the keyboard interactively',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Builds the list of items for the scroll view.
  List<Widget> _buildScrollViewItems() {
    return [
      _buildExampleCard(
        title: 'Multiline Text Field',
        description: 'A text field with multiple lines that demonstrates interactive keyboard dismissal.',
        child: TextField(
          controller: _controllers[0],
          focusNode: _focusNodes[0],
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            hintText: 'Start typing here...',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      _buildExampleCard(
        title: 'Single Line Text Field',
        description: 'A standard single-line text field.',
        child: TextField(
          controller: _controllers[1],
          focusNode: _focusNodes[1],
          decoration: const InputDecoration(
            hintText: 'Enter some text',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      _buildExampleCard(
        title: 'Email Input',
        description: 'Text field optimized for email input.',
        child: TextField(
          controller: _controllers[2],
          focusNode: _focusNodes[2],
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Enter your email',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
        ),
      ),
      _buildExampleCard(
        title: 'Number Input',
        description: 'Text field for numeric input.',
        child: TextField(
          controller: _controllers[3],
          focusNode: _focusNodes[3],
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter a number',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.numbers),
          ),
        ),
      ),
      _buildExampleCard(
        title: 'Text Form Field',
        description: 'Using TextFormField instead of TextField.',
        child: TextFormField(
          controller: _controllers[4],
          focusNode: _focusNodes[4],
          decoration: const InputDecoration(
            hintText: 'Form field example',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      const SizedBox(height: 100), // Extra space at the bottom
    ];
  }

  /// Builds a card containing an example with title and description.
  Widget _buildExampleCard({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  /// Shows an information dialog explaining the example.
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simple Scroll View Example'),
        content: const Text(
          'This example demonstrates the basic usage of CupertinoInteractiveKeyboard. '
          'The widget wraps a ListView containing various text input fields.\n\n'
          'On iOS devices, you can tap any text field to show the keyboard, then '
          'drag down on the text field to interactively dismiss the keyboard. '
          'This provides a native iOS-like experience.\n\n'
          'The interactive dismissal only works on iOS devices and requires the '
          'CupertinoInteractiveKeyboard wrapper.',
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

/// Sample text content for demonstration purposes.
const String _kSampleText = '''This is a sample text that demonstrates the interactive keyboard dismissal functionality. 

You can edit this text and add more content. On iOS devices, try dragging down while the keyboard is visible to see the interactive dismissal in action.

The text field supports multiple lines and will expand as you type more content. This simulates real-world usage scenarios where users interact with longer text content.

Try typing here and then use the interactive dismissal gesture to hide the keyboard!''';
