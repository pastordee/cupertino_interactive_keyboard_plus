import 'package:flutter/material.dart';

import 'package:cupertino_interactive_keyboard/src/persistent_frame_notifier.dart';

/// A mixin that provides awareness of whether the current route is active.
///
/// This mixin tracks the current route's state and notifies when the route
/// becomes current or non-current. This is useful for widgets that need to
/// pause or resume certain operations based on route visibility, such as
/// platform method calls that should only be active for the current route.
///
/// The mixin automatically handles:
/// - Tracking route changes through [ModalRoute.of(context)]
/// - Using persistent frame callbacks to monitor route state
/// - Providing [isRouteCurrent] getter for current state
/// - Calling [didChangeRouteCurrentState] when state changes
///
/// Example usage:
/// ```dart
/// class MyWidget extends StatefulWidget {
///   // widget implementation
/// }
///
/// class _MyWidgetState extends State<MyWidget> with CurrentRouteAware {
///   @override
///   void didChangeRouteCurrentState() {
///     super.didChangeRouteCurrentState();
///     if (isRouteCurrent) {
///       // Resume operations
///     } else {
///       // Pause operations
///     }
///   }
/// }
/// ```
mixin CurrentRouteAware<T extends StatefulWidget> on State<T> {
  /// Whether the current route is active.
  ///
  /// Returns `true` if the route containing this widget is currently
  /// the active route in the navigation stack, `false` otherwise.
  bool get isRouteCurrent => _isRouteCurrent;

  bool _isRouteCurrent = false;
  ModalRoute<dynamic>? _currentRoute;
  final PersistentFrameNotifier _frameNotifier = PersistentFrameNotifier();

  @override
  void initState() {
    super.initState();
    _frameNotifier.addListener(_frameCallback);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentRoute = ModalRoute.of(context);
    _frameCallback();
  }

  @override
  void dispose() {
    super.dispose();
    _frameNotifier.removeListener(_frameCallback);
    _frameNotifier.dispose();
  }

  /// Called when the route's current state changes.
  ///
  /// Override this method to respond to route state changes.
  /// The [isRouteCurrent] getter will reflect the new state
  /// when this method is called.
  ///
  /// Make sure to call `super.didChangeRouteCurrentState()` when overriding.
  @mustCallSuper
  void didChangeRouteCurrentState() {}

  void _frameCallback() {
    final newIsCurrent = _currentRoute?.isCurrent ?? true;
    if (_isRouteCurrent != newIsCurrent) {
      _isRouteCurrent = newIsCurrent;
      didChangeRouteCurrentState();
    }
  }
}
