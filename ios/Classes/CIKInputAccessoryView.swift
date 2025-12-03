import UIKit
import os.log

/// A custom input accessory view that manages dynamic height based on Flutter widgets.
///
/// This view serves as an input accessory view for text input fields and automatically
/// adjusts its height based on the maximum height of all registered Flutter input
/// accessory widgets. It integrates with the keyboard system to provide proper
/// layout calculations.
///
/// ## Key Features
/// - Dynamic height adjustment based on Flutter widget heights
/// - Automatic registration with `KeyboardManager`
/// - Transparent hit testing (passes touches through)
/// - Auto Layout integration with intrinsic content size
final class CIKInputAccessoryView: UIView, KeyboardManagedObject {
  
  /// Dictionary mapping view IDs to their corresponding input accessory heights.
  ///
  /// The view's height is automatically set to the maximum of all registered heights.
  /// When this property is updated, the height constraint is adjusted accordingly.
  var inputAccessoryHeights = [Int: Double]() {
    didSet {
      let newHeight = inputAccessoryHeights.values.max() ?? 0
      heightConstraint.constant = newHeight
      os_log("Updated input accessory height to %f", log: Self.logger, type: .debug, newHeight)
      invalidateIntrinsicContentSize()
    }
  }
  
  /// The height constraint that controls this view's height.
  private lazy var heightConstraint = heightAnchor.constraint(equalToConstant: 0)
  
  /// Logger for this class.
  private static let logger = OSLog(subsystem: "cupertino_interactive_keyboard_plus", category: "input_accessory")
  
  /// Initializes the input accessory view with common configuration.
  ///
  /// - Parameter frame: The frame rectangle for the view.
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  /// Initializes the input accessory view from a coder (for storyboards/nibs).
  ///
  /// - Parameter coder: The coder containing the view's data.
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }
  
  /// The intrinsic content size of the view.
  ///
  /// Returns a size with no intrinsic width (allowing it to fill available space)
  /// and a height equal to the current height constraint constant.
  ///
  /// - Returns: The intrinsic content size.
  override var intrinsicContentSize: CGSize {
    return CGSize(width: UIView.noIntrinsicMetric, height: heightConstraint.constant)
  }
  
  /// Performs common initialization for all initializers.
  ///
  /// Sets up the view for use as an input accessory view:
  /// - Disables autoresizing mask translation
  /// - Activates the height constraint
  private func commonInit() {
    translatesAutoresizingMaskIntoConstraints = false
    heightConstraint.isActive = true
    os_log("CIKInputAccessoryView initialized", log: Self.logger, type: .debug)
  }
  
  /// Called when the view is added to or removed from a window.
  ///
  /// Registers or unregisters this input accessory view with the `KeyboardManager`
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
  
  /// Registers this input accessory view with the KeyboardManager.
  func registerWithKeyboardManager() {
    KeyboardManager.shared.activeInputAccessoryViews.add(self)
    os_log("CIKInputAccessoryView registered with keyboard manager", log: Self.logger, type: .debug)
  }
  
  /// Unregisters this input accessory view from the KeyboardManager.
  func unregisterFromKeyboardManager() {
    KeyboardManager.shared.activeInputAccessoryViews.remove(self)
    os_log("CIKInputAccessoryView unregistered from keyboard manager", log: Self.logger, type: .debug)
  }
  
  /// Returns the view that should receive touch events at the specified point.
  ///
  /// This implementation always returns `nil`, making the view transparent to touches.
  /// This allows touches to pass through to views behind this input accessory view.
  ///
  /// - Parameters:
  ///   - point: The point to test, in the receiver's coordinate system.
  ///   - event: The event that prompted the hit test.
  /// - Returns: Always `nil` to pass touches through.
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    return nil
  }
}
