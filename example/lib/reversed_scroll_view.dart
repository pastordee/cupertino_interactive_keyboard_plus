import 'package:cupertino_interactive_keyboard_plus/cupertino_interactive_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// An advanced example demonstrating CupertinoInteractiveKeyboard with reversed scrolling.
/// 
/// This screen showcases how the interactive keyboard dismissal functionality works
/// with reversed scroll views, commonly used in chat interfaces and messaging apps.
/// The reversed scroll direction ensures new content appears at the bottom while
/// maintaining the natural keyboard dismissal behavior.
/// 
/// ## Key Features Demonstrated:
/// - Interactive keyboard dismissal with reversed scroll physics
/// - Chat-like interface with reversed ListView
/// - Dynamic content addition at the bottom
/// - Proper focus management in reversed views
/// - Simulated messaging functionality
/// 
/// ## Technical Implementation:
/// Uses a reversed ListView.builder to create a chat-like interface where new
/// messages appear at the bottom. The CupertinoInteractiveKeyboard wrapper
/// ensures that keyboard dismissal gestures work naturally even with the
/// reversed scroll direction.
class ReversedScrollView extends StatefulWidget {
  const ReversedScrollView({super.key});

  @override
  State<ReversedScrollView> createState() => _ReversedScrollViewState();
}

class _ReversedScrollViewState extends State<ReversedScrollView> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  int _messageCounter = 0;

  @override
  void initState() {
    super.initState();
    _initializeMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  /// Initializes the chat with some sample messages.
  void _initializeMessages() {
    final sampleMessages = [
      'Welcome to the Reversed Scroll View example! 👋',
      'This demonstrates interactive keyboard dismissal in a chat-like interface.',
      'Notice how new messages appear at the bottom...',
      'Try typing a message and then drag down on the keyboard to dismiss it!',
      'The reversed scroll ensures the latest content is always visible.',
    ];

    for (int i = 0; i < sampleMessages.length; i++) {
      _messages.add(ChatMessage(
        id: _messageCounter++,
        text: sampleMessages[i],
        timestamp: DateTime.now().subtract(Duration(minutes: sampleMessages.length - i)),
        isFromUser: i % 2 == 0,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reversed Scroll View'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _showInstructions,
            icon: const Icon(Icons.help_outline),
            tooltip: 'Show instructions',
          ),
          IconButton(
            onPressed: _showInfoDialog,
            icon: const Icon(Icons.info_outline),
            tooltip: 'Show example information',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusBanner(),
          Expanded(
            child: CupertinoInteractiveKeyboard(
              child: Column(
                children: [
                  Expanded(
                    child: _buildMessageList(),
                  ),
                  _buildMessageInput(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the status banner indicating platform compatibility.
  Widget _buildStatusBanner() {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    
    return Container(
      width: double.infinity,
      color: isIOS 
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            isIOS ? Icons.chat_bubble_outline : Icons.info,
            color: isIOS 
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onErrorContainer,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isIOS 
                ? 'Chat interface with interactive keyboard dismissal enabled'
                : 'Interactive keyboard dismissal only works on iOS devices',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isIOS 
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the reversed message list.
  Widget _buildMessageList() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: ListView.builder(
        controller: _scrollController,
        reverse: true, // This creates the chat-like behavior
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length + 1, // +1 for the header
        itemBuilder: (context, index) {
          if (index == _messages.length) {
            // Header at the top (which appears at the bottom due to reverse)
            return _buildChatHeader();
          }
          
          final message = _messages[_messages.length - 1 - index];
          return _buildMessageBubble(message);
        },
      ),
    );
  }

  /// Builds the chat header explaining the example.
  Widget _buildChatHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.keyboard_arrow_down,
            size: 32,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(height: 8),
          Text(
            'Reversed Scroll View Demo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'This chat interface uses a reversed ListView. New messages appear at the bottom, '
            'and you can still use interactive keyboard dismissal by dragging down on the keyboard.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds a message bubble for the chat interface.
  Widget _buildMessageBubble(ChatMessage message) {
    final isFromUser = message.isFromUser;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isFromUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(
                Icons.smart_toy,
                size: 16,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isFromUser 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: !isFromUser ? Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isFromUser 
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isFromUser 
                        ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isFromUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.person,
                size: 16,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the message input area at the bottom.
  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _inputFocusNode,
                decoration: InputDecoration(
                  hintText: 'Type a message... (try dragging down to dismiss keyboard)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              onPressed: _sendMessage,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  /// Sends a new message to the chat.
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        id: _messageCounter++,
        text: text,
        timestamp: DateTime.now(),
        isFromUser: true,
      ));
    });

    _messageController.clear();
    
    // Simulate a bot response after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _addBotResponse(text);
      }
    });
  }

  /// Adds a simulated bot response.
  void _addBotResponse(String userMessage) {
    final responses = [
      'Thanks for testing the reversed scroll view! 🎉',
      'Did you try dragging down on the keyboard to dismiss it?',
      'Notice how new messages appear at the bottom naturally.',
      'The reversed ListView makes this feel like a real chat app!',
      'Interactive keyboard dismissal works seamlessly here.',
      'Great message! This demonstrates the functionality perfectly.',
      'The keyboard behavior feels native and intuitive.',
    ];

    setState(() {
      _messages.add(ChatMessage(
        id: _messageCounter++,
        text: responses[_messageCounter % responses.length],
        timestamp: DateTime.now(),
        isFromUser: false,
      ));
    });
  }

  /// Formats a timestamp for display.
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  /// Shows instructions for using the example.
  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Use This Example'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This example demonstrates interactive keyboard dismissal in a reversed scroll view:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('1. Tap the message input field at the bottom'),
              SizedBox(height: 8),
              Text('2. Type a message and send it'),
              SizedBox(height: 8),
              Text('3. On iOS: While the keyboard is visible, place your finger on it and drag down'),
              SizedBox(height: 8),
              Text('4. Notice how the keyboard dismisses smoothly following your gesture'),
              SizedBox(height: 8),
              Text('5. Observe that new messages appear at the bottom (reversed scrolling)'),
              SizedBox(height: 12),
              Text(
                'This pattern is commonly used in messaging apps where the most recent content should be immediately visible.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
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

  /// Shows detailed information about the example.
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reversed Scroll View Example'),
        content: const Text(
          'This example showcases CupertinoInteractiveKeyboard with reversed scrolling.\n\n'
          'Key features:\n'
          '• Interactive keyboard dismissal in a chat interface\n'
          '• Reversed ListView for natural message ordering\n'
          '• Dynamic content addition at the bottom\n'
          '• Proper focus management\n'
          '• Simulated messaging functionality\n\n'
          'The reversed scroll direction is commonly used in chat apps, '
          'messaging interfaces, and social media feeds where the newest '
          'content should appear at the bottom and be immediately visible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Represents a chat message in the interface.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isFromUser,
  });

  final int id;
  final String text;
  final DateTime timestamp;
  final bool isFromUser;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
