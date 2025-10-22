import Flutter
import UIKit
import os.log

/// A Flutter plugin that provides interactive keyboard dismissal functionality for iOS.
///
/// This plugin enables native iOS-style interactive keyboard dismissal in Flutter applications,
/// allowing users to drag down the keyboard to dismiss it interactively, similar to native iOS apps.
///
/// ## Key Features
/// - Interactive keyboard dismissal with pan gestures
/// - Input accessory view support
/// - Scrollable area detection and management
/// - Integration with Flutter's text input system
///
/// ## Usage
/// The plugin automatically registers itself and sets up necessary swizzling when initialized.
/// Flutter widgets communicate with this plugin through method channels to register scrollable
/// areas and input accessory views.
public class CupertinoInteractiveKeyboardPlugin: NSObject, FlutterPlugin {
  /// Registers the plugin with the Flutter plugin registrar.
  ///
  /// This method sets up the plugin instance, initializes the keyboard manager,
  /// performs necessary method swizzling, and establishes the method channel
  /// for communication with Flutter.
  ///
  /// - Parameter registrar: The Flutter plugin registrar for this plugin.
  public static func register(with registrar: FlutterPluginRegistrar) {
    _ = KeyboardManager.shared
    swizzleFlutterViewController()
    swizzleFlutterTextInputView()
    
    let channel = FlutterMethodChannel(name: "cupertino_interactive_keyboard", binaryMessenger: registrar.messenger())
    let instance = CupertinoInteractiveKeyboardPlugin()
    instance.methodChannel = channel
    registrar.publish(instance)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  
  /// Retrieves the plugin instance for a given Flutter plugin registry.
  ///
  /// - Parameter registry: The Flutter plugin registry to search.
  /// - Returns: The plugin instance if found, otherwise `nil`.
  static func instance(for registry: FlutterPluginRegistry) -> CupertinoInteractiveKeyboardPlugin? {
    registry.valuePublished(byPlugin: "CupertinoInteractiveKeyboardPlugin") as? CupertinoInteractiveKeyboardPlugin
  }
  
  /// The custom scroll view that handles interactive keyboard dismissal gestures.
  let scrollView = CIKScrollView()
  
  /// The input accessory view that manages input accessory heights.
  let inputView = CIKInputAccessoryView()
  
  /// The Flutter method channel for communication with Dart.
  private var methodChannel: FlutterMethodChannel?
  
  /// Logger for this plugin.
  private static let logger = OSLog(subsystem: "cupertino_interactive_keyboard", category: "plugin")
    
  override init() {
    super.init()
    setupKeyboardNotifications()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  /// Sets up observers for keyboard notifications.
  private func setupKeyboardNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow(_:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide(_:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
    
    os_log("Keyboard notifications set up", log: Self.logger, type: .info)
  }
  
  /// Called when the keyboard will show.
  @objc private func keyboardWillShow(_ notification: Notification) {
    os_log("Keyboard will show", log: Self.logger, type: .debug)
    methodChannel?.invokeMethod("onKeyboardVisibilityChanged", arguments: true)
  }
  
  /// Called when the keyboard will hide.
  @objc private func keyboardWillHide(_ notification: Notification) {
    os_log("Keyboard will hide", log: Self.logger, type: .debug)
    methodChannel?.invokeMethod("onKeyboardVisibilityChanged", arguments: false)
  }
  
  /// Handles method calls from Flutter.
  ///
  /// This method processes commands from the Flutter side to manage scrollable rectangles
  /// and input accessory heights. All UI operations are performed on the main queue.
  ///
  /// - Parameters:
  ///   - call: The method call from Flutter containing the method name and arguments.
  ///   - result: The result callback to return values or errors to Flutter.
  ///
  /// ## Supported Methods
  /// - `initialize`: Sets up the plugin with the Flutter view controller
  /// - `setScrollableRect`: Registers a scrollable area for gesture recognition
  /// - `removeScrollableRect`: Unregisters a scrollable area
  /// - `setInputAccessoryHeight`: Sets the height for an input accessory view
  /// - `removeInputAccessoryHeight`: Removes an input accessory view height
  ///
  /// ## Error Handling
  /// Returns `FlutterMethodNotImplemented` for unknown methods or invalid arguments.
  /// Logs errors and returns appropriate error codes for operational failures.
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      guard
        let args = call.arguments as? [String: Any],
        let firstTime = args["firstTime"] as? Bool
      else {
        os_log("Invalid arguments for initialize method", log: Self.logger, type: .error)
        return result(FlutterError(
          code: "INVALID_ARGUMENTS",
          message: "initialize method requires 'firstTime' boolean argument",
          details: nil
        ))
      }
      
      DispatchQueue.main.async {
        if firstTime {
          self.scrollView.scrollableRects = [:]
          self.inputView.inputAccessoryHeights = [:]
        }
        
        guard let flutterViewController = self.findFlutterViewController() else {
          os_log("Failed to find Flutter view controller during initialization", log: Self.logger, type: .error)
          return result(FlutterError(
            code: "NO_FLUTTER_VIEW_CONTROLLER",
            message: "Could not find FlutterViewController instance",
            details: nil
          ))
        }
        
        if self.scrollView.superview != flutterViewController.view {
          self.scrollView.removeFromSuperview()
          self.scrollView.frame = flutterViewController.view.bounds
          flutterViewController.view.addSubview(self.scrollView)
        }
        
        result(true)
      }
      
    case "setScrollableRect":
      guard
        let args = call.arguments as? [String: Any],
        let id = args["id"] as? Int,
        let rectMap = args["rect"] as? [String: Double],
        let x = rectMap["x"],
        let y = rectMap["y"],
        let width = rectMap["width"],
        let height = rectMap["height"]
      else {
        os_log("Invalid arguments for setScrollableRect method", log: Self.logger, type: .error)
        return result(FlutterError(
          code: "INVALID_ARGUMENTS",
          message: "setScrollableRect requires 'id' (Int) and 'rect' (map with x,y,width,height)",
          details: nil
        ))
      }
      
      DispatchQueue.main.async {
        self.scrollView.scrollableRects[id] = CGRect(x: x, y: y, width: width, height: height)
        os_log("Set scrollable rect for id %d: %@", log: Self.logger, type: .debug, id, NSCoder.string(for: CGRect(x: x, y: y, width: width, height: height)))
        result(nil)
      }
      
    case "removeScrollableRect":
      guard
        let args = call.arguments as? [String: Any],
        let id = args["id"] as? Int
      else {
        os_log("Invalid arguments for removeScrollableRect method", log: Self.logger, type: .error)
        return result(FlutterError(
          code: "INVALID_ARGUMENTS",
          message: "removeScrollableRect requires 'id' (Int) argument",
          details: nil
        ))
      }
      
      DispatchQueue.main.async {
        self.scrollView.scrollableRects[id] = nil
        os_log("Removed scrollable rect for id %d", log: Self.logger, type: .debug, id)
        result(nil)
      }
      
    case "setInputAccessoryHeight":
      guard
        let args = call.arguments as? [String: Any],
        let id = args["id"] as? Int,
        let height = args["height"] as? Double
      else {
        os_log("Invalid arguments for setInputAccessoryHeight method", log: Self.logger, type: .error)
        return result(FlutterError(
          code: "INVALID_ARGUMENTS",
          message: "setInputAccessoryHeight requires 'id' (Int) and 'height' (Double) arguments",
          details: nil
        ))
      }
      
      DispatchQueue.main.async {
        self.inputView.inputAccessoryHeights[id] = height
        result(nil)
      }
      
    case "removeInputAccessoryHeight":
      guard
        let args = call.arguments as? [String: Any],
        let id = args["id"] as? Int
      else {
        os_log("Invalid arguments for removeInputAccessoryHeight method", log: Self.logger, type: .error)
        return result(FlutterError(
          code: "INVALID_ARGUMENTS",
          message: "removeInputAccessoryHeight requires 'id' (Int) argument",
          details: nil
        ))
      }
      
      DispatchQueue.main.async {
        self.inputView.inputAccessoryHeights[id] = nil
        result(nil)
      }
      
    default:
      os_log("Unknown method called: %@", log: Self.logger, type: .error, call.method)
      result(FlutterMethodNotImplemented)
    }
  }
  
  /// Called when the plugin is detached from the Flutter engine.
  ///
  /// This method performs cleanup by clearing all registered scrollable rectangles
  /// and input accessory heights to prevent memory leaks and stale references.
  ///
  /// - Parameter registrar: The Flutter plugin registrar (unused).
  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    os_log("Detaching plugin from engine", log: Self.logger, type: .info)
    scrollView.scrollableRects.removeAll()
    inputView.inputAccessoryHeights.removeAll()
  }
  
  /// Finds the FlutterViewController associated with this plugin instance.
  ///
  /// This method searches through the view controller hierarchy to find the
  /// FlutterViewController that contains this plugin instance. It handles
  /// both iOS 13+ scene-based apps and legacy window-based apps.
  ///
  /// - Returns: The associated FlutterViewController, or nil if not found.
  private func findFlutterViewController() -> FlutterViewController? {
    /// Checks if a view controller is the target FlutterViewController.
    ///
    /// - Parameter viewController: The view controller to check.
    /// - Returns: The FlutterViewController if it matches, otherwise nil.
    func checkViewController(_ viewController: UIViewController) -> FlutterViewController? {
      if
        let flutterViewController = viewController as? FlutterViewController,
        CupertinoInteractiveKeyboardPlugin.instance(for: flutterViewController) === self
      {
        return flutterViewController
      }
      return nil
    }
    
    /// Recursively searches for the target FlutterViewController in a view controller hierarchy.
    ///
    /// - Parameter viewController: The root view controller to search from.
    /// - Returns: The FlutterViewController if found, otherwise nil.
    func findInViewController(_ viewController: UIViewController) -> FlutterViewController? {
      if let flutterViewController = checkViewController(viewController) {
        return flutterViewController
      }
      
      for child in viewController.children {
        if let flutterViewController = findInViewController(child) {
          return flutterViewController
        }
      }
      
      return nil
    }
    
    /// Searches for the target FlutterViewController in an array of windows.
    ///
    /// - Parameter windows: The windows to search through.
    /// - Returns: The FlutterViewController if found, otherwise nil.
    func findInWindows(_ windows: [UIWindow]) -> FlutterViewController? {
      for window in windows {
        if let rootViewController = window.rootViewController,
           let flutterViewController = findInViewController(rootViewController) {
          return flutterViewController
        }
      }
      return nil
    }
    
    // Search in scene-based apps (iOS 13+) or legacy window-based apps
    if #available(iOS 13.0, *) {
      for case let windowScene as UIWindowScene in UIApplication.shared.connectedScenes {
        if let viewController = findInWindows(windowScene.windows) {
          os_log("Found FlutterViewController in scene-based app", log: Self.logger, type: .debug)
          return viewController
        }
      }
      os_log("FlutterViewController not found in any scene", log: Self.logger, type: .debug)
      return nil
    } else {
      if let viewController = findInWindows(UIApplication.shared.windows) {
        os_log("Found FlutterViewController in legacy app", log: Self.logger, type: .debug)
        return viewController
      }
      os_log("FlutterViewController not found in legacy app", log: Self.logger, type: .debug)
      return nil
    }
  }
}

