import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:cupertino_interactive_keyboard/cupertino_interactive_keyboard_platform_interface.dart';
import 'package:cupertino_interactive_keyboard/src/current_route_aware.dart';
import 'package:cupertino_interactive_keyboard/src/height_observer.dart';

/// Global counter for generating unique view IDs for input accessories.
int _nextViewId = 0;

/// A widget that provides input accessory functionality on iOS.
///
/// This widget tracks the height of its child and communicates this information
/// to the native iOS implementation to properly handle keyboard layout when
/// using input accessory views. On iOS, it provides the necessary integration
/// for custom input accessory views. On other platforms, it simply returns
/// the child widget without any modifications.
///
/// Input accessory views are typically used to add custom toolbars or
/// controls above the keyboard.
///
/// Example usage:
/// ```dart
/// CupertinoInputAccessory(
///   child: Container(
///     height: 44,
///     child: Row(
///       children: [
///         TextButton(onPressed: () {}, child: Text('Done')),
///       ],
///     ),
///   ),
/// )
/// ```
class CupertinoInputAccessory extends StatelessWidget {
  /// Creates a [CupertinoInputAccessory] widget.
  ///
  /// The [child] parameter is required and represents the input accessory
  /// content that will be tracked for height changes on iOS.
  const CupertinoInputAccessory({super.key, required this.child});

  /// The widget below this widget in the tree.
  /// This typically contains the input accessory UI elements.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return IOSCupertinoInputAccessory(child: child);
    } else {
      return child;
    }
  }
}

/// iOS-specific implementation of input accessory functionality.
///
/// This widget handles the height tracking and platform communication
/// for input accessory views on iOS devices. It monitors the height
/// of its child widget and reports changes to the native implementation.
class IOSCupertinoInputAccessory extends StatefulWidget {
  const IOSCupertinoInputAccessory({super.key, required this.child});

  final Widget child;

  @override
  State<StatefulWidget> createState() => _IOSCupertinoInputAccessory();
}

class _IOSCupertinoInputAccessory extends State<IOSCupertinoInputAccessory>
    with CurrentRouteAware {
  final _viewId = _nextViewId++;
  double? _latestHeight;

  @override
  void dispose() {
    super.dispose();
    CupertinoInteractiveKeyboardPlatform.instance
        .removeInputAccessoryHeight(_viewId);
  }

  @override
  void didChangeRouteCurrentState() {
    super.didChangeRouteCurrentState();
    _reportHeight();
  }

  @override
  Widget build(BuildContext context) {
    return HeightObserver(
      onChange: (height) {
        _latestHeight = height;
        _reportHeight();
      },
      child: widget.child,
    );
  }

  void _reportHeight() {
    if (!isRouteCurrent) {
      CupertinoInteractiveKeyboardPlatform.instance
          .removeInputAccessoryHeight(_viewId);
    } else if (_latestHeight != null) {
      CupertinoInteractiveKeyboardPlatform.instance
          .setInputAccessoryHeight(_viewId, _latestHeight!);
    }
  }
}
