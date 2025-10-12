import Foundation

/// Exchanges the implementations of two selectors on a given class.
///
/// This function uses the Objective-C runtime to swap the implementations of two methods.
/// It's commonly used for method swizzling to intercept and modify method calls.
///
/// ## Usage
/// ```swift
/// let success = exchangeSelectors(
///   FlutterViewController.self,
///   #selector(originalMethod),
///   #selector(swizzledMethod)
/// )
/// ```
///
/// ## Safety Considerations
/// - Both selectors must exist on the specified class
/// - The method signatures should be compatible
/// - This operation affects all instances of the class
/// - Should typically be performed only once during app initialization
///
/// - Parameters:
///   - type: The class on which to perform the method exchange.
///   - firstSelector: The first selector to exchange.
///   - secondSelector: The second selector to exchange.
/// - Returns: `true` if the exchange was successful, `false` if either method was not found.
@discardableResult
func exchangeSelectors(_ type: AnyClass, _ firstSelector: Selector, _ secondSelector: Selector) -> Bool {
    guard
        let firstMethod = class_getInstanceMethod(type, firstSelector),
        let secondMethod = class_getInstanceMethod(type, secondSelector)
    else {
        return false
    }
    
    method_exchangeImplementations(firstMethod, secondMethod)
    return true
}
