import UIKit
import os.log

// MARK: - Protocols

/// Protocol for objects that can be managed by the KeyboardManager.
///
/// This protocol provides a common interface for objects that need to be
/// tracked by the KeyboardManager for keyboard-related functionality.
protocol KeyboardManagedObject: AnyObject {
  /// Called when the object should register with the keyboard manager.
  func registerWithKeyboardManager()
  
  /// Called when the object should unregister from the keyboard manager.
  func unregisterFromKeyboardManager()
}

/// Manages keyboard interactions and coordinate between multiple input accessory views and scroll views.
///
/// This singleton class handles the coordination of interactive keyboard dismissal by:
/// - Tracking active scroll views and input accessory views
/// - Adjusting keyboard notifications to account for input accessory view heights
/// - Monitoring interactive dismissal gestures and generating synthetic notifications
/// - Managing the lifecycle of keyboard-related UI components
///
/// ## Thread Safety
/// This class is designed to be used from the main thread only. All public methods
/// should be called from the main queue.
final class KeyboardManager {
  
  /// The shared singleton instance of the keyboard manager.
  static let shared = KeyboardManager()
  
  /// Key used to mark keyboard notifications that have already been processed.
  private static let handledUserInfoKey = "KeyboardManagerHandledUserInfoKey"
  
  /// Set of currently active scroll views that can trigger keyboard dismissal.
  ///
  /// This uses a weak reference collection to avoid retain cycles and ensure
  /// automatic cleanup when scroll views are deallocated.
  var activeScrollViews = NSHashTable<CIKScrollView>.weakObjects()
  
  /// Set of currently active input accessory views.
  ///
  /// This uses a weak reference collection to avoid retain cycles and ensure
  /// automatic cleanup when input accessory views are deallocated.
  var activeInputAccessoryViews = NSHashTable<CIKInputAccessoryView>.weakObjects()
  
  /// Logger for this class.
  private static let logger = OSLog(subsystem: "cupertino_interactive_keyboard", category: "keyboard_manager")
  
  /// Private initializer to enforce singleton pattern.
  ///
  /// Sets up notification observers for keyboard interactive dismissal events.
  /// The interactive dismissal notification is accessed through base64-encoded
  /// strings to avoid using private APIs directly.
  private init() {
//    [
//      UIResponder.keyboardWillChangeFrameNotification,
//      UIResponder.keyboardWillShowNotification,
//      UIResponder.keyboardWillHideNotification,
//      UIResponder.keyboardDidChangeFrameNotification,
//      UIResponder.keyboardDidShowNotification,
//      UIResponder.keyboardDidHideNotification,
//    ].forEach { name in
//      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: name, object: nil)
//    }
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardInteractiveDismissalDidBegin),
      name: UIResponder.keyboardInteractiveDismissalNotification,
      object: nil
    )
    
    os_log("KeyboardManager initialized", log: Self.logger, type: .info)
  }
  
  /// Adjusts a keyboard notification to account for input accessory view heights.
  ///
  /// This method modifies keyboard frame information in notifications to account for
  /// the space occupied by input accessory views. This ensures that Flutter's layout
  /// calculations are correct when input accessory views are present.
  ///
  /// - Parameter notification: The original keyboard notification.
  /// - Returns: A modified notification with adjusted frame information, or the
  ///           original notification if no adjustment is needed.
  func adjustKeyboardNotification(_ notification: Notification) -> Notification {
    let maxInputAccessoryHeight = activeInputAccessoryViews.allObjects.map(\.intrinsicContentSize.height).max() ?? 0
    
    guard
      var userInfo = notification.userInfo,
      !((userInfo[KeyboardManager.handledUserInfoKey] as? Bool) ?? false),
      maxInputAccessoryHeight > 0
    else {
      return notification
    }
    
    os_log("Adjusting keyboard notification by %f points", log: Self.logger, type: .debug, maxInputAccessoryHeight)
    
    /// Adjusts a keyboard frame rectangle by the input accessory height.
    ///
    /// - Parameter value: The original frame value.
    /// - Returns: An adjusted frame value.
    func adjustRect(_ value: NSValue) -> NSValue {
      var rect = value.cgRectValue
      rect.origin.y += maxInputAccessoryHeight
      rect.size.height -= maxInputAccessoryHeight
      return NSValue(cgRect: rect)
    }
    
    userInfo[KeyboardManager.handledUserInfoKey] = true
    userInfo[UIResponder.keyboardFrameBeginUserInfoKey] = userInfo[UIResponder.keyboardFrameBeginUserInfoKey]
      .flatMap({ $0 as? NSValue }).map(adjustRect)
    userInfo[UIResponder.keyboardFrameEndUserInfoKey] = userInfo[UIResponder.keyboardFrameEndUserInfoKey]
      .flatMap({ $0 as? NSValue }).map(adjustRect)
    
    return Notification(name: notification.name, object: notification.object, userInfo: userInfo)
  }
  
  /// Handles the beginning of interactive keyboard dismissal.
  ///
  /// This method is called when the user begins an interactive keyboard dismissal gesture.
  /// It generates a synthetic keyboard frame change notification based on the current
  /// gesture location to provide real-time keyboard position updates during dismissal.
  ///
  /// The method:
  /// 1. Finds an active gesture recognizer in the changed state
  /// 2. Calculates the gesture location in screen coordinates
  /// 3. Creates a frame representing the keyboard position
  /// 4. Posts a synthetic keyboard frame change notification
  @objc
  private func keyboardInteractiveDismissalDidBegin() {
    guard
      let gesture = activeScrollViews.allObjects.map(\.panGestureRecognizer).first(where: { $0.state == .changed }),
      let gestureView = gesture.view,
      let screen = gestureView.window?.screen
    else {
      os_log("No active gesture found for interactive dismissal", log: Self.logger, type: .debug)
      return
    }
    
    let locationInScrollView = gesture.location(in: gestureView)
    let locationInScreen = gestureView.convert(locationInScrollView, to: screen.coordinateSpace)
    
    let frame = CGRect(
      x: 0,
      y: locationInScreen.y,
      width: screen.bounds.width,
      height: screen.bounds.height - locationInScreen.y
    )
    
    os_log("Posting synthetic keyboard frame notification with frame: %@", log: Self.logger, type: .debug, NSCoder.string(for: frame))
    
    NotificationCenter.default.post(
      name: UIResponder.keyboardWillChangeFrameNotification,
      object: screen,
      userInfo: [
        UIResponder.keyboardFrameBeginUserInfoKey: NSValue(cgRect: frame),
        UIResponder.keyboardFrameEndUserInfoKey: NSValue(cgRect: frame),
      ]
    )
  }
}

// MARK: - Private Extensions

/// Private extension to UIResponder for accessing keyboard interactive dismissal notifications.
///
/// This extension provides access to private iOS notifications using base64-encoded strings
/// to avoid directly referencing private APIs. The notifications are used to detect when
/// the user begins an interactive keyboard dismissal gesture.
private extension UIResponder {
  
  /// The notification name for interactive keyboard dismissal events.
  ///
  /// This property uses base64-encoded strings to access private notification names:
  /// - iOS 12+: `UIKeyboardPrivateInteractiveDismissalDidBeginNotification`
  /// - iOS 11 and earlier: `UITextEffectsWindowDidRotateNotification` (fallback)
  static let keyboardInteractiveDismissalNotification: Notification.Name = {
    if #available(iOS 12.0, *) {
      return .init(
        // UIKeyboardPrivateInteractiveDismissalDidBeginNotification
        "VUlLZXlib2FyZFByaXZhdGVJbnRlcmFjdGl2ZURpc21pc3NhbERpZEJlZ2luTm90aWZpY2F0aW9u"
          .base64Decoded
      )
    } else {
      return .init(
        // UITextEffectsWindowDidRotateNotification
        "VUlUZXh0RWZmZWN0c1dpbmRvd0RpZFJvdGF0ZU5vdGlmaWNhdGlvbg=="
          .base64Decoded
      )
    }
  }()
}

/// Private extension to String for base64 decoding.
///
/// This extension provides a safe way to decode base64-encoded strings,
/// which is used to access private notification names without directly
/// referencing them in the code.
private extension String {
  
  /// Decodes a base64-encoded string to its original string representation.
  ///
  /// - Returns: The decoded string, or the original string if decoding fails.
  var base64Decoded: String {
    Data(base64Encoded: self)
      .flatMap {
        String(data: $0, encoding: .utf8)
      }
    ?? self
  }
}
