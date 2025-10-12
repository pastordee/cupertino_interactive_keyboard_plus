import UIKit
import os.log

/// A custom scroll view that enables interactive keyboard dismissal functionality.
///
/// This scroll view acts as an invisible overlay that captures pan gestures within
/// registered scrollable rectangles and translates them into keyboard dismissal actions.
/// It works in conjunction with the system's `keyboardDismissMode` to provide
/// native iOS-style interactive keyboard dismissal.
///
/// ## Key Features
/// - Transparent overlay that doesn't interfere with normal touch handling
/// - Selective gesture recognition based on registered scrollable areas
/// - Integration with iOS keyboard dismissal APIs
/// - Automatic lifecycle management through `KeyboardManager`
final class CIKScrollView: UIScrollView, UIGestureRecognizerDelegate, KeyboardManagedObject {
  
  /// Dictionary mapping view IDs to their corresponding scrollable rectangles.
  ///
  /// These rectangles define the areas where pan gestures should be recognized
  /// for keyboard dismissal. Coordinates are in the coordinate system of the
  /// scroll view's superview.
  var scrollableRects = [Int: CGRect]()
  
  /// Logger for this class.
  private static let logger = OSLog(subsystem: "cupertino_interactive_keyboard", category: "scroll_view")
  
  /// Initializes the scroll view with common configuration.
  ///
  /// - Parameter frame: The frame rectangle for the view.
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  /// Initializes the scroll view from a coder (for storyboards/nibs).
  ///
  /// - Parameter coder: The coder containing the view's data.
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }
  
  /// Performs common initialization for all initializers.
  ///
  /// Sets up the scroll view properties needed for interactive keyboard dismissal:
  /// - Auto-resizing behavior
  /// - Interactive keyboard dismissal mode
  /// - Large content size for scrolling
  /// - Non-interfering gesture recognition
  /// - Hidden visibility (acts as overlay)
  private func commonInit() {
    autoresizingMask = [.flexibleWidth, .flexibleHeight]
    keyboardDismissMode = .interactiveWithAccessory
    contentSize = CGSize(width: 10, height: 10000)
    panGestureRecognizer.cancelsTouchesInView = false
    isHidden = true
  }
  
  /// Called when the view is added to or removed from a window.
  ///
  /// Registers or unregisters this scroll view with the `KeyboardManager`
  /// to manage its lifecycle and active state.
  override func didMoveToWindow() {
    super.didMoveToWindow()
    if window != nil {
      registerWithKeyboardManager()
    } else {
      unregisterFromKeyboardManager()
    }
  }
  
  // MARK: - KeyboardManagedObject
  
  /// Registers this scroll view with the KeyboardManager.
  func registerWithKeyboardManager() {
    KeyboardManager.shared.activeScrollViews.add(self)
    os_log("CIKScrollView registered with keyboard manager", log: Self.logger, type: .debug)
  }
  
  /// Unregisters this scroll view from the KeyboardManager.
  func unregisterFromKeyboardManager() {
    KeyboardManager.shared.activeScrollViews.remove(self)
    os_log("CIKScrollView unregistered from keyboard manager", log: Self.logger, type: .debug)
  }
  
  /// Called when the view is added to or removed from a superview.
  ///
  /// Adds the pan gesture recognizer to the superview to enable
  /// gesture recognition across the entire view hierarchy.
  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    if let superview = superview {
      superview.addGestureRecognizer(panGestureRecognizer)
      os_log("Pan gesture recognizer added to superview", log: Self.logger, type: .debug)
    }
  }
  
  /// Determines whether a gesture recognizer should begin.
  ///
  /// This method only allows the pan gesture to begin if:
  /// 1. The gesture is our pan gesture recognizer
  /// 2. The superclass allows the gesture to begin
  /// 3. The gesture location is within one of the registered scrollable rectangles
  ///
  /// - Parameter gestureRecognizer: The gesture recognizer attempting to begin.
  /// - Returns: `true` if the gesture should begin, `false` otherwise.
  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    let location = gestureRecognizer.location(in: gestureRecognizer.view)
    let shouldBegin = gestureRecognizer == panGestureRecognizer
      && super.gestureRecognizerShouldBegin(gestureRecognizer)
      && scrollableRects.contains(where: { $0.value.contains(location) })
    
    if shouldBegin {
      os_log("Gesture began at location %@", log: Self.logger, type: .debug, NSCoder.string(for: location))
    }
    
    return shouldBegin
  }
  
  // MARK: - UIGestureRecognizerDelegate
  
  /// Allows simultaneous recognition with other gesture recognizers.
  ///
  /// This ensures that our keyboard dismissal gesture doesn't interfere
  /// with other gestures in the app, such as scrolling within Flutter widgets.
  ///
  /// - Parameters:
  ///   - gestureRecognizer: Our gesture recognizer.
  ///   - otherGestureRecognizer: Another gesture recognizer.
  /// - Returns: Always `true` to allow simultaneous recognition.
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    return true
  }
  
  /// Determines if our gesture should require another gesture to fail.
  ///
  /// - Parameters:
  ///   - gestureRecognizer: Our gesture recognizer.
  ///   - otherGestureRecognizer: Another gesture recognizer.
  /// - Returns: Always `false` to avoid requiring other gestures to fail.
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    return false
  }
  
  /// Determines if another gesture should require our gesture to fail.
  ///
  /// - Parameters:
  ///   - gestureRecognizer: Our gesture recognizer.
  ///   - otherGestureRecognizer: Another gesture recognizer.
  /// - Returns: Always `false` to avoid blocking other gestures.
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    return false
  }
}
