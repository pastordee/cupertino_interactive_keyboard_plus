import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Callback function type for widget rectangle changes.
///
/// Called whenever the observed widget's global rectangle changes,
/// providing the new [Rect] coordinates and dimensions.
typedef OnWidgetRectChange = void Function(Rect rect);

/// A widget that observes and reports changes to its child's rectangle.
///
/// This widget tracks the global position and size of its child widget,
/// calling the [onChange] callback whenever the rectangle changes.
/// This is useful for tracking widget positions for platform communication
/// or layout-dependent operations.
///
/// The rectangle is reported in global coordinates relative to the
/// entire screen, making it suitable for platform method calls that
/// need absolute positioning information.
///
/// Example usage:
/// ```dart
/// RectObserver(
///   onChange: (rect) {
///     print('Widget is at: ${rect.topLeft}, size: ${rect.size}');
///   },
///   child: Container(
///     width: 100,
///     height: 100,
///     color: Colors.blue,
///   ),
/// )
/// ```
class RectObserver extends SingleChildRenderObjectWidget {
  /// Creates a [RectObserver] widget.
  ///
  /// The [onChange] callback is required and will be called whenever
  /// the child widget's global rectangle changes.
  ///
  /// The [child] parameter is required and represents the widget
  /// whose rectangle will be observed.
  const RectObserver({
    super.key,
    required this.onChange,
    required Widget super.child,
  });

  /// Callback function called when the child's rectangle changes.
  final OnWidgetRectChange onChange;

  @override
  RectObserverRenderObject createRenderObject(BuildContext context) =>
      RectObserverRenderObject(onChange);

  @override
  void updateRenderObject(
    BuildContext context,
    RectObserverRenderObject renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

/// Render object that tracks rectangle changes for a widget.
///
/// This render object monitors its child's global position and size,
/// triggering callbacks when the rectangle changes. It uses post-frame
/// callbacks to ensure layout is complete before calculating positions.
class RectObserverRenderObject extends RenderProxyBox {
  RectObserverRenderObject(this.onChange);

  Rect? oldRect;
  OnWidgetRectChange onChange;
  bool _frameCallbackScheduled = false;

  @override
  void performLayout() {
    super.performLayout();

    if (!_frameCallbackScheduled) {
      _frameCallbackScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _frameCallbackScheduled = false;
        final child = this.child;
        if (child == null) return;

        final newOffset = child.localToGlobal(Offset.zero);
        final newSize = child.size;
        final newRect = Rect.fromLTWH(
          newOffset.dx,
          newOffset.dy,
          newSize.width,
          newSize.height,
        );

        if (newRect != oldRect) {
          oldRect = newRect;
          onChange(newRect);
        }
      });
    }
  }
}
