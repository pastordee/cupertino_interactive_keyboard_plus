import UIKit
import Flutter
import os.log

/// Key for associating cached input accessory views with UIResponder instances.
private var cachedInputAccessoryViewKey: UInt8 = 0

/// Performs method swizzling on FlutterTextInputView to provide custom input accessory views.
///
/// This function swizzles the `inputAccessoryView` property getter on FlutterTextInputView
/// to return our custom input accessory view instead of the default implementation.
///
/// - Returns: `true` if swizzling succeeded, `false` otherwise.
@discardableResult
func swizzleFlutterTextInputView() -> Bool {
  swizzleFlutterTextInputViewOnce
}

/// Ensures that FlutterTextInputView swizzling is performed only once.
///
/// This lazy property performs the actual method swizzling using a dispatch_once-like
/// pattern. It looks up the FlutterTextInputView class by name and swizzles the
/// inputAccessoryView property getter.
private let swizzleFlutterTextInputViewOnce: Bool = {
  let originalSelector = #selector(getter: UIResponder.inputAccessoryView)
  let replacementSelector = #selector(getter: UIResponder.cik_inputAccessoryView)
  let logger = OSLog(subsystem: "cupertino_interactive_keyboard", category: "swizzling")
  
  guard let type = NSClassFromString("FlutterTextInputView") else {
    os_log("Failed to find FlutterTextInputView class", log: logger, type: .error)
    return false
  }
  
  let success = exchangeSelectors(type, originalSelector, replacementSelector)
  os_log("FlutterTextInputView swizzling completed: %@", log: logger, type: .info, success ? "SUCCESS" : "FAILED")
  
  return success
}()

// MARK: - UIResponder Extension

/// Extension to UIResponder that provides input accessory view functionality.
///
/// This extension adds methods and properties to manage custom input accessory views
/// for Flutter text input fields. It uses associated objects to cache input accessory
/// view instances and provides the swizzled implementation.
extension UIResponder {
  /// Cached input accessory view for this responder.
  ///
  /// This property uses associated objects to store a cached reference to the
  /// input accessory view, avoiding repeated lookups and ensuring consistent
  /// behavior across multiple accesses.
  @nonobjc
  private var cachedInputAccessoryView: UIView? {
    get {
      objc_getAssociatedObject(self, &cachedInputAccessoryViewKey) as? UIView
    }
    set {
      objc_setAssociatedObject(self, &cachedInputAccessoryViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  /// Swizzled implementation of the `inputAccessoryView` property getter.
  ///
  /// This method provides a custom input accessory view from the CupertinoInteractiveKeyboardPlugin
  /// when available. It follows this logic:
  /// 1. Return cached view if available
  /// 2. Look up the plugin instance for the current Flutter view controller
  /// 3. Return the plugin's input accessory view and cache it
  /// 4. Return nil if no plugin is found
  ///
  /// - Returns: The custom input accessory view, or nil if not available.
  @objc
  dynamic fileprivate var cik_inputAccessoryView: UIView? {
    if let inputView = cachedInputAccessoryView {
      return inputView
    } else if
      let viewController = flutterViewController,
      let plugin = CupertinoInteractiveKeyboardPlugin.instance(for: viewController)
    {
      let inputView = plugin.inputView
      cachedInputAccessoryView = inputView
      return inputView
    } else {
      return nil
    }
  }
  
  /// Finds the FlutterViewController in the responder chain.
  ///
  /// This method traverses the responder chain starting from the current responder
  /// to find the containing FlutterViewController instance.
  ///
  /// - Returns: The FlutterViewController if found, otherwise nil.
  @nonobjc
  private var flutterViewController: FlutterViewController? {
    var parentResponder: UIResponder? = self.next
    while parentResponder != nil {
      if let viewController = parentResponder as? FlutterViewController {
        return viewController
      }
      parentResponder = parentResponder?.next
    }
    return nil
  }
}
