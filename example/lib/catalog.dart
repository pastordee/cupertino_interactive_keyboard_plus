import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// A catalog screen that showcases different examples of the Cupertino Interactive Keyboard plugin.
/// 
/// This screen serves as the main navigation hub for exploring various interactive keyboard
/// dismissal scenarios. Each example demonstrates specific features and use cases of the plugin.
/// 
/// The catalog includes:
/// - Basic scroll view integration
/// - Input accessory view functionality
/// - Nested navigation scenarios
/// - Reversed scroll view handling
/// 
/// Each example includes a description of what it demonstrates and why it's useful.
class Catalog extends StatelessWidget {
  const Catalog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Keyboard Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeaderCard(context),
                const SizedBox(height: 16),
                ...(_buildExamplesList(context)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the header card with plugin information and platform notice.
  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.keyboard,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cupertino Interactive Keyboard',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Interactive keyboard dismissal for Flutter',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: defaultTargetPlatform == TargetPlatform.iOS
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    defaultTargetPlatform == TargetPlatform.iOS
                        ? Icons.check_circle
                        : Icons.info,
                    color: defaultTargetPlatform == TargetPlatform.iOS
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      defaultTargetPlatform == TargetPlatform.iOS
                          ? 'Running on iOS - Interactive keyboard dismissal is active'
                          : 'Running on ${defaultTargetPlatform.name} - Interactive features only work on iOS',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: defaultTargetPlatform == TargetPlatform.iOS
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the list of example cards.
  List<Widget> _buildExamplesList(BuildContext context) {
    final examples = [
      ExampleInfo(
        title: 'Simple Scroll View',
        description: 'Basic integration with a ListView containing text input. '
                    'Demonstrates the fundamental interactive keyboard dismissal behavior.',
        icon: Icons.view_list,
        route: '/simple_scroll_view',
        features: ['Basic keyboard dismissal', 'ListView integration', 'Text input handling'],
      ),
      ExampleInfo(
        title: 'Input Accessory',
        description: 'Shows how to add custom input accessory views above the keyboard. '
                    'Useful for chat interfaces and commenting systems.',
        icon: Icons.keyboard_alt,
        route: '/input_accessory',
        features: ['Custom input accessory', 'Dynamic height adjustment', 'Chat-like interface'],
      ),
      ExampleInfo(
        title: 'Nested Navigation',
        description: 'Demonstrates behavior with nested navigation stacks. '
                    'Shows how the plugin handles route changes and maintains state.',
        icon: Icons.navigation,
        route: '/nested_navigation',
        features: ['Navigation awareness', 'Route state management', 'Multi-screen apps'],
      ),
      ExampleInfo(
        title: 'Reversed Scroll View',
        description: 'Integration with reversed scroll views, commonly used in chat applications. '
                    'Tests keyboard behavior with bottom-anchored content.',
        icon: Icons.flip,
        route: '/reversed_scroll_view',
        features: ['Reversed scrolling', 'Bottom-anchored content', 'Chat app patterns'],
      ),
    ];

    return examples.map((example) => _buildExampleCard(context, example)).toList();
  }

  /// Builds an individual example card.
  Widget _buildExampleCard(BuildContext context, ExampleInfo example) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, example.route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      example.icon,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          example.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          example.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: example.features.map((feature) => Chip(
                  label: Text(
                    feature,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  side: BorderSide.none,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Information about an example in the catalog.
/// 
/// This class encapsulates the metadata for each example, including
/// its title, description, icon, navigation route, and key features.
class ExampleInfo {
  const ExampleInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.features,
  });

  /// The display title of the example.
  final String title;
  
  /// A detailed description of what the example demonstrates.
  final String description;
  
  /// The icon to display for this example.
  final IconData icon;
  
  /// The navigation route to this example.
  final String route;
  
  /// List of key features demonstrated by this example.
  final List<String> features;
}
