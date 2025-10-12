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
  const CupertinoInteractiveKeyboard({super.key, required this.child});

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return IOSCupertinoInteractiveKeyboard(child: child);
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
  const IOSCupertinoInteractiveKeyboard({super.key, required this.child});

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  State<StatefulWidget> createState() =>
      _IOSCupertinoInteractiveKeyboardState();
}

class _IOSCupertinoInteractiveKeyboardState
    extends State<IOSCupertinoInteractiveKeyboard> with CurrentRouteAware {
  final _viewId = _nextViewId++;
  Rect? _latestRect;

  @override
  void initState() {
    super.initState();
    CupertinoInteractiveKeyboardPlatform.instance
        .initialize(firstTime: _firstTime);
    _firstTime = false;
  }

  @override
  void dispose() {
    super.dispose();
    CupertinoInteractiveKeyboardPlatform.instance.removeScrollableRect(_viewId);
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
