import 'package:flutter/widgets.dart';

/// Custom scroll physics for interactive keyboard behavior.
///
/// This scroll physics implementation provides special handling for scroll
/// position adjustments when the viewport dimensions change during keyboard
/// interactions. It prevents unwanted scroll position changes when the
/// keyboard appears or disappears while the user is actively scrolling.
///
/// The physics specifically handles the case where:
/// - The user is currently scrolling
/// - The scroll direction is upward (AxisDirection.up)
/// - The viewport dimensions have changed (typically due to keyboard)
///
/// In this scenario, it maintains the current scroll position rather than
/// allowing the default scroll position adjustment, providing a smoother
/// user experience during keyboard interactions.
class InteractiveKeyboardScrollPhysics extends ScrollPhysics {
  /// Creates [InteractiveKeyboardScrollPhysics] with an optional parent.
  ///
  /// The [parent] parameter allows chaining with other scroll physics
  /// to combine behaviors.
  const InteractiveKeyboardScrollPhysics({super.parent});

  @override
  InteractiveKeyboardScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return InteractiveKeyboardScrollPhysics(parent: buildParent(ancestor));
  }

  /// Adjusts the scroll position when viewport dimensions change.
  ///
  /// This override provides special handling during active scrolling
  /// when the viewport dimensions change (typically due to keyboard
  /// appearance/disappearance). It preserves the current scroll position
  /// to prevent jarring scroll adjustments during keyboard interactions.
  ///
  /// Returns the old scroll position if:
  /// - The user is currently scrolling ([isScrolling] is true)
  /// - The scroll direction is upward ([AxisDirection.up])
  /// - The viewport dimensions have changed
  ///
  /// Otherwise, delegates to the parent implementation.
  @override
  double adjustPositionForNewDimensions({
    required ScrollMetrics oldPosition,
    required ScrollMetrics newPosition,
    required bool isScrolling,
    required double velocity,
  }) {
    // Preserve scroll position during active upward scrolling when viewport changes
    if (isScrolling &&
        newPosition.axisDirection == AxisDirection.up &&
        oldPosition.viewportDimension != newPosition.viewportDimension) {
      return oldPosition.pixels;
    }

    return super.adjustPositionForNewDimensions(
      oldPosition: oldPosition,
      newPosition: newPosition,
      isScrolling: isScrolling,
      velocity: velocity,
    );
  }
}
