import 'package:cupertino_interactive_keyboard_plus/cupertino_interactive_keyboard_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// An implementation of [CupertinoInteractiveKeyboardPlatform] that uses method channels.
///
/// This implementation provides the concrete platform communication layer
/// for iOS interactive keyboard functionality. It handles all method channel
/// calls to the native iOS implementation and includes proper error handling
/// with descriptive error messages.
///
/// The class communicates with the native iOS plugin through the
/// 'cupertino_interactive_keyboard' method channel, sending structured
/// data for scrollable rectangles and input accessory heights.
class MethodChannelCupertinoInteractiveKeyboard
    extends CupertinoInteractiveKeyboardPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('cupertino_interactive_keyboard_plus');

  /// Callback for keyboard visibility changes from the platform.
  PlatformKeyboardVisibilityCallback? _keyboardVisibilityCallback;

  /// Constructor that sets up the method call handler.
  MethodChannelCupertinoInteractiveKeyboard() {
    methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  /// Handles method calls from the native platform.
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onKeyboardVisibilityChanged':
        final bool isVisible = call.arguments as bool;
        _keyboardVisibilityCallback?.call(isVisible);
        break;
      default:
        debugPrint('[MethodChannel] Unknown method: ${call.method}');
    }
  }

  @override
  void setKeyboardVisibilityCallback(PlatformKeyboardVisibilityCallback? callback) {
    _keyboardVisibilityCallback = callback;
  }

  @override
  Future<bool?> initialize({required bool firstTime}) {
    try {
      return methodChannel.invokeMethod<bool>('initialize', {
        'firstTime': firstTime,
      });
    } catch (e) {
      throw PlatformException(
        code: 'INITIALIZATION_FAILED',
        message: 'Failed to initialize cupertino interactive keyboard',
        details: e.toString(),
      );
    }
  }

  @override
  Future<void> setScrollableRect(int id, Rect rect) {
    try {
      return methodChannel.invokeMethod('setScrollableRect', {
        'id': id,
        'rect': {
          'x': rect.left,
          'y': rect.top,
          'width': rect.width,
          'height': rect.height,
        },
      });
    } catch (e) {
      throw PlatformException(
        code: 'SET_SCROLLABLE_RECT_FAILED',
        message: 'Failed to set scrollable rect for id $id',
        details: e.toString(),
      );
    }
  }

  @override
  Future<void> removeScrollableRect(int id) {
    try {
      return methodChannel.invokeMethod('removeScrollableRect', {
        'id': id,
      });
    } catch (e) {
      throw PlatformException(
        code: 'REMOVE_SCROLLABLE_RECT_FAILED',
        message: 'Failed to remove scrollable rect for id $id',
        details: e.toString(),
      );
    }
  }

  @override
  Future<void> setInputAccessoryHeight(int id, double height) {
    try {
      return methodChannel.invokeMethod('setInputAccessoryHeight', {
        'id': id,
        'height': height,
      });
    } catch (e) {
      throw PlatformException(
        code: 'SET_INPUT_ACCESSORY_HEIGHT_FAILED',
        message: 'Failed to set input accessory height for id $id',
        details: e.toString(),
      );
    }
  }

  @override
  Future<void> removeInputAccessoryHeight(int id) {
    try {
      return methodChannel.invokeMethod('removeInputAccessoryHeight', {
        'id': id,
      });
    } catch (e) {
      throw PlatformException(
        code: 'REMOVE_INPUT_ACCESSORY_HEIGHT_FAILED',
        message: 'Failed to remove input accessory height for id $id',
        details: e.toString(),
      );
    }
  }
}
