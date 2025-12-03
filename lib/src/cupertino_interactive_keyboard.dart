import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:cupertino_interactive_keyboard/src/cupertino_interactive_keyboard_platform_interface.dart';
import 'package:cupertino_interactive_keyboard/src/current_route_aware.dart';
import 'package:cupertino_interactive_keyboard/src/interactive_keyboard_scroll_physics.dart';
import 'package:cupertino_interactive_keyboard/src/rect_observer.dart';

/// Global flag to track if this is the first initialization.
bool _firstTime = true;

/// Global counter for generating unique view IDs.
int _nextViewId = 0;

/// Callback function type for keyboard visibility changes.
///
/// Called whenever the keyboard visibility state changes,
/// providing a boolean indicating whether the keyboard is visible.
typedef OnKeyboardVisibilityChanged = void Function(bool isVisible);

/// A widget that enables interactive keyboard dismissal behavior on iOS.
///
/// This widget wraps its child with platform-specific behavior that allows
/// users to interactively dismiss the keyboard by scrolling. On iOS, it
/// provides the native-like keyboard dismissal experience. On other platforms,
/// it simply returns the child widget without any modifications.
///
/// Example usage:
/// ```dart
/// CupertinoInteractiveKeyboard(
///   onKeyboardVisibilityChanged: (isVisible) {
///     print('Keyboard is ${isVisible ? 'visible' : 'hidden'}');
///   },
///   child: ListView(
///     children: [
///       TextField(),
///       // Other widgets...
///     ],
///   ),
/// )
/// ```
class CupertinoInteractiveKeyboard extends StatelessWidget {
  /// Creates a [CupertinoInteractiveKeyboard] widget.
  ///
  /// The [child] parameter is required and represents the widget tree
  /// that will be wrapped with interactive keyboard behavior on iOS.
  ///
  /// The [onKeyboardVisibilityChanged] callback is optional and will be
  /// called whenever the keyboard visibility changes (shows or hides).
  const CupertinoInteractiveKeyboard({
    super.key,
    required this.child,
    this.onKeyboardVisibilityChanged,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// Optional callback that fires when keyboard visibility changes.
  ///
  /// Called with `true` when the keyboard becomes visible and `false`
  /// when it is dismissed. This allows the app to respond to keyboard
  /// visibility changes, such as adjusting UI elements or notifying
  /// other systems.
  final OnKeyboardVisibilityChanged? onKeyboardVisibilityChanged;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return IOSCupertinoInteractiveKeyboard(
        onKeyboardVisibilityChanged: onKeyboardVisibilityChanged,
        child: child,
      );
    } else {
      return child;
    }
  }
}

/// iOS-specific implementation of interactive keyboard behavior.
///
/// This widget handles the actual platform communication and state management
/// for interactive keyboard dismissal on iOS devices. It tracks the widget's
/// position and communicates with the native iOS implementation to provide
/// smooth keyboard dismissal interactions.
class IOSCupertinoInteractiveKeyboard extends StatefulWidget {
  /// Creates an [IOSCupertinoInteractiveKeyboard] widget.
  ///
  /// The [child] parameter is required and represents the widget tree
  /// that will be tracked for interactive keyboard behavior.
  ///
  /// The [onKeyboardVisibilityChanged] callback is optional and will be
  /// called whenever the keyboard visibility changes.
  const IOSCupertinoInteractiveKeyboard({
    super.key,
    required this.child,
    this.onKeyboardVisibilityChanged,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// Optional callback that fires when keyboard visibility changes.
  final OnKeyboardVisibilityChanged? onKeyboardVisibilityChanged;

  @override
  State<StatefulWidget> createState() =>
      _IOSCupertinoInteractiveKeyboardState();
}

class _IOSCupertinoInteractiveKeyboardState
    extends State<IOSCupertinoInteractiveKeyboard> 
    with CurrentRouteAware {
  final _viewId = _nextViewId++;
  Rect? _latestRect;

  @override
  void initState() {
    super.initState();
    CupertinoInteractiveKeyboardPlatform.instance
        .initialize(firstTime: _firstTime);
    _firstTime = false;
    
    // Set up platform callback to receive keyboard visibility changes from iOS
    if (widget.onKeyboardVisibilityChanged != null) {
      CupertinoInteractiveKeyboardPlatform.instance.setKeyboardVisibilityCallback(
        (isVisible) {
          widget.onKeyboardVisibilityChanged?.call(isVisible);
        },
      );
    }
  }

  @override
  void dispose() {
    // Clear the platform callback
    CupertinoInteractiveKeyboardPlatform.instance.setKeyboardVisibilityCallback(null);
    CupertinoInteractiveKeyboardPlatform.instance.removeScrollableRect(_viewId);
    super.dispose();
  }

  @override
  void didChangeRouteCurrentState() {
    super.didChangeRouteCurrentState();
    _reportRect();
  }

  @override
  Widget build(BuildContext context) {
    final scrollBehavior = ScrollConfiguration.of(context);
    final newScrollPhysics = const InteractiveKeyboardScrollPhysics().applyTo(
      scrollBehavior.getScrollPhysics(context),
    );
    final newScrollBehavior =
        scrollBehavior.copyWith(physics: newScrollPhysics);

    return ScrollConfiguration(
      behavior: newScrollBehavior,
      child: RectObserver(
        onChange: (rect) {
          _latestRect = rect;
          _reportRect();
        },
        child: widget.child,
      ),
    );
  }

  void _reportRect() {
    if (!isRouteCurrent) {
      CupertinoInteractiveKeyboardPlatform.instance
          .removeScrollableRect(_viewId);
    } else if (_latestRect != null) {
      CupertinoInteractiveKeyboardPlatform.instance
          .setScrollableRect(_viewId, _latestRect!);
    }
  }
}
