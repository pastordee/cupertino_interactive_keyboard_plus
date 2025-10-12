import UIKit
import Flutter
import os.log

/// Performs method swizzling on FlutterViewController to intercept keyboard notifications.
///
/// This function swizzles keyboard-related methods on FlutterViewController to allow
/// the plugin to modify keyboard notifications before they reach Flutter's internal
/// handling. This is necessary to account for input accessory view heights.
///
/// - Returns: `true` if at least one swizzling operation succeeded, `false` otherwise.
@discardableResult
func swizzleFlutterViewController() -> Bool {
  swizzleFlutterViewControllerOnce
}

/// Ensures that FlutterViewController swizzling is performed only once.
///
/// This lazy property performs the actual method swizzling using a dispatch_once-like
/// pattern to ensure the operations are performed exactly once, even in multi-threaded
/// environments.
private let swizzleFlutterViewControllerOnce: Bool = {
  let type = FlutterViewController.self
  let logger = OSLog(subsystem: "cupertino_interactive_keyboard", category: "swizzling")
  
  let results = [
    exchangeSelectors(type, NSSelectorFromString("keyboardWillChangeFrame:"), #selector(FlutterViewController.cik_keyboardWillChangeFrame)),
    exchangeSelectors(type, NSSelectorFromString("keyboardWillBeHidden:"), #selector(FlutterViewController.cik_keyboardWillBeHidden)),
    exchangeSelectors(type, NSSelectorFromString("keyboardWillShowNotification:"), #selector(FlutterViewController.cik_keyboardWillShowNotification)),
  ]
  
  let success = results.contains(true)
  os_log("FlutterViewController swizzling completed: %@", log: logger, type: .info, success ? "SUCCESS" : "FAILED")
  
  return success
}()

// MARK: - FlutterViewController Extension

/// Extension to FlutterViewController that provides swizzled method implementations.
///
/// These methods are swapped with the original FlutterViewController methods to intercept
/// keyboard notifications and apply input accessory height adjustments before passing
/// them to the original implementations.
extension FlutterViewController {
  /// Swizzled implementation of `keyboardWillChangeFrame:`.
  ///
  /// This method intercepts keyboard frame change notifications, applies input accessory
  /// height adjustments through the KeyboardManager, and then calls the original implementation.
  ///
  /// - Parameter notification: The keyboard notification to process.
  @objc
  dynamic fileprivate func cik_keyboardWillChangeFrame(_ notification: Notification?) {
    cik_keyboardWillChangeFrame(notification.map(KeyboardManager.shared.adjustKeyboardNotification(_:)))
  }
  
  /// Swizzled implementation of `keyboardWillBeHidden:`.
  ///
  /// This method intercepts keyboard hide notifications, applies input accessory
  /// height adjustments through the KeyboardManager, and then calls the original implementation.
  ///
  /// - Parameter notification: The keyboard notification to process.
  @objc
  dynamic fileprivate func cik_keyboardWillBeHidden(_ notification: Notification?) {
    cik_keyboardWillBeHidden(notification.map(KeyboardManager.shared.adjustKeyboardNotification(_:)))
  }
  
  /// Swizzled implementation of `keyboardWillShowNotification:`.
  ///
  /// This method intercepts keyboard show notifications, applies input accessory
  /// height adjustments through the KeyboardManager, and then calls the original implementation.
  ///
  /// - Parameter notification: The keyboard notification to process.
  @objc
  dynamic fileprivate func cik_keyboardWillShowNotification(_ notification: Notification?) {
    cik_keyboardWillShowNotification(notification.map(KeyboardManager.shared.adjustKeyboardNotification(_:)))
  }
}
