import 'package:cupertino_interactive_keyboard/cupertino_interactive_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// An example demonstrating input accessory view functionality.
/// 
/// This screen showcases how to use CupertinoInputAccessory to add custom views
/// above the keyboard. This is particularly useful for chat interfaces, commenting
/// systems, and other apps that need persistent input controls.
/// 
/// ## Key Features Demonstrated:
/// - CupertinoInputAccessory integration
/// - Dynamic input accessory height
/// - Chat-like interface with scrollable content
/// - Send button and text clearing functionality
/// - Material Design input accessory styling
/// 
/// ## How It Works:
/// The input accessory view appears above the keyboard and maintains its position
/// as the keyboard animates. The plugin automatically adjusts the keyboard layout
/// to account for the accessory view's height.
class InputAccessory extends StatefulWidget {
  const InputAccessory({super.key});

  @override
  State<StatefulWidget> createState() => _InputAccessoryState();
}

class _InputAccessoryState extends State<InputAccessory> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
   bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeMessages();
    _inputController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Initializes the chat with some sample messages.
  void _initializeMessages() {
    _messages.addAll([
      ChatMessage(
        text: 'Welcome to the Input Accessory example!',
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatMessage(
        text: 'This demonstrates how to add custom input accessories above the keyboard.',
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
      ChatMessage(
        text: 'Try typing a message below and sending it.',
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      ChatMessage(
        text: 'On iOS, you can drag down to dismiss the keyboard interactively.',
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ]);
  }

  /// Called when the text in the input field changes.
  void _onTextChanged() {
    setState(() {
      // Rebuild to update send button state
    });
  }

  /// Sends a message and clears the input field.
  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _inputController.clear();
    });

    // Scroll to bottom after adding message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Accessory'),
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
          if (defaultTargetPlatform != TargetPlatform.iOS)
            _buildPlatformWarning(),
          Expanded(
            child: CupertinoInteractiveKeyboard(
              onKeyboardVisibilityChanged: (isVisible) {
                setState(() {
                  _isKeyboardVisible = isVisible;
                });
                
                // You can notify your system here
                print('Keyboard visibility changed: $isVisible');
                
                // Example: Notify other parts of your app
                // yourService.notifyKeyboardState(isVisible);
              },
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: _messages.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
              ),
            ),
          ),
          CupertinoInputAccessory(
            child: _buildInputAccessory(),
          ),
        ],
      ),
    );
  }

  /// Builds the platform warning banner for non-iOS platforms.
  Widget _buildPlatformWarning() {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.errorContainer,
      padding: const EdgeInsets.all(12),
      child: Text(
        'Input accessory features work best on iOS devices',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Builds the input accessory view with text field and send button.
  Widget _buildInputAccessory() {
    return Material(
      elevation: 8,
      shadowColor: Theme.of(context).shadowColor.withOpacity(0.5),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _inputController,
                      focusNode: _inputFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _inputController.text.trim().isNotEmpty
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _inputController.text.trim().isNotEmpty ? _sendMessage : null,
                    icon: Icon(
                      Icons.send,
                      color: _inputController.text.trim().isNotEmpty
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    tooltip: 'Send message',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a message bubble for the chat interface.
  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: message.isUser ? const Radius.circular(4) : null,
            bottomLeft: message.isUser ? null : const Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: message.isUser
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: (message.isUser
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant).withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formats a timestamp for display in message bubbles.
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Shows an information dialog explaining the example.
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Input Accessory Example'),
        content: const Text(
          'This example demonstrates how to use CupertinoInputAccessory to add '
          'custom views above the keyboard.\n\n'
          'The input accessory view contains a text field and send button that '
          'stays positioned above the keyboard. This is commonly used in chat '
          'applications and commenting systems.\n\n'
          'Key features:\n'
          '• Custom input accessory view\n'
          '• Dynamic height adjustment\n'
          '• Interactive keyboard dismissal (iOS only)\n'
          '• Chat-like interface design',
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

/// Represents a chat message in the example.
class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  /// The message text content.
  final String text;
  
  /// Whether this message was sent by the user.
  final bool isUser;
  
  /// When the message was sent.
  final DateTime timestamp;
}
