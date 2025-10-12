import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Callback function type for widget height changes.
///
/// Called whenever the observed widget's height changes,
/// providing the new height value in logical pixels.
typedef OnWidgetHeightChange = void Function(double height);

/// A widget that observes and reports changes to its child's height.
///
/// This widget tracks the height of its child widget, calling the
/// [onChange] callback whenever the height changes. This is particularly
/// useful for input accessory views or other UI elements where height
/// changes need to be communicated to platform implementations.
///
/// The height is measured during the layout phase, ensuring accurate
/// measurements based on the widget's final rendered size.
///
/// Example usage:
/// ```dart
/// HeightObserver(
///   onChange: (height) {
///     print('Widget height changed to: $height');
///   },
///   child: Container(
///     height: 44,
///     child: TextField(),
///   ),
/// )
/// ```
class HeightObserver extends SingleChildRenderObjectWidget {
  /// Creates a [HeightObserver] widget.
  ///
  /// The [onChange] callback is required and will be called whenever
  /// the child widget's height changes.
  ///
  /// The [child] parameter is required and represents the widget
  /// whose height will be observed.
  const HeightObserver({
    super.key,
    required this.onChange,
    required Widget super.child,
  });

  /// Callback function called when the child's height changes.
  final OnWidgetHeightChange onChange;

  @override
  HeightObserverRenderObject createRenderObject(BuildContext context) =>
      HeightObserverRenderObject(onChange);

  @override
  void updateRenderObject(
    BuildContext context,
    HeightObserverRenderObject renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

/// Render object that tracks height changes for a widget.
///
/// This render object monitors its child's height during layout,
/// triggering callbacks when the height changes. It provides
/// immediate notification during the layout phase for responsive
/// height tracking.
class HeightObserverRenderObject extends RenderProxyBox {
  HeightObserverRenderObject(this.onChange);

  double? oldHeight;
  OnWidgetHeightChange onChange;

  @override
  void performLayout() {
    super.performLayout();

    final child = this.child;
    if (child == null) return;

    final newHeight = child.size.height;
    if (newHeight != oldHeight) {
      oldHeight = newHeight;
      onChange(newHeight);
    }
  }
}
