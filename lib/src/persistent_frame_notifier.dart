import 'package:flutter/widgets.dart';

/// A singleton value notifier that provides persistent frame callbacks.
///
/// This class provides a shared instance that notifies listeners on every
/// frame using Flutter's persistent frame callback mechanism. It's designed
/// to be used by multiple widgets that need frame-based updates without
/// each widget setting up its own frame callback.
///
/// The notifier:
/// - Uses a singleton pattern to share one instance across the app
/// - Sets up persistent frame callbacks automatically
/// - Provides the current frame timestamp to listeners
/// - Cannot be disposed (dispose() is overridden to be a no-op)
///
/// This is particularly useful for widgets that need to check state
/// changes on every frame, such as route awareness or animation updates.
class PersistentFrameNotifier extends ValueNotifier<Duration> {
  /// Returns the singleton instance of [PersistentFrameNotifier].
  ///
  /// All widgets should use this factory constructor to get the
  /// shared instance rather than creating multiple instances.
  factory PersistentFrameNotifier() => _instance;

  /// Private constructor that sets up the persistent frame callback.
  ///
  /// This constructor initializes the notifier with [Duration.zero] and
  /// sets up a persistent frame callback that will notify listeners
  /// with the current frame timestamp on every frame.
  PersistentFrameNotifier._() : super(Duration.zero) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // We need to add this callback on post frame because otherwise
      // Concurrent modification exception it thrown
      WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
        value = timeStamp;
      });
    });
  }

  /// The singleton instance of [PersistentFrameNotifier].
  static final PersistentFrameNotifier _instance = PersistentFrameNotifier._();

  /// Override dispose to prevent disposal of the singleton instance.
  ///
  /// Since this is a singleton that may be used by multiple widgets,
  /// it should not be disposed when individual widgets are disposed.
  /// The persistent frame callback will continue running for the
  /// lifetime of the application.
  @override
  // ignore: must_call_super
  void dispose() {}
}
