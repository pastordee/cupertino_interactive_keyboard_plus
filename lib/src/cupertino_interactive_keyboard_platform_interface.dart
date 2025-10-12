import 'dart:ui';

import 'package:cupertino_interactive_keyboard/cupertino_interactive_keyboard_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The platform interface for the cupertino_interactive_keyboard plugin.
///
/// This abstract class defines the interface that platform-specific
/// implementations must follow to provide interactive keyboard functionality.
/// It handles communication between Flutter and the native iOS implementation.
abstract class CupertinoInteractiveKeyboardPlatform extends PlatformInterface {
  /// Constructs a CupertinoInteractiveKeyboardPlatform.
  CupertinoInteractiveKeyboardPlatform() : super(token: _token);

  static final Object _token = Object();

  static CupertinoInteractiveKeyboardPlatform _instance =
      MethodChannelCupertinoInteractiveKeyboard();

  /// The default instance of [CupertinoInteractiveKeyboardPlatform] to use.
  ///
  /// Defaults to [MethodChannelCupertinoInteractiveKeyboard].
  static CupertinoInteractiveKeyboardPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CupertinoInteractiveKeyboardPlatform] when
  /// they register themselves.
  static set instance(CupertinoInteractiveKeyboardPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initializes the platform implementation.
  ///
  /// This method should be called once to set up the native implementation.
  /// The [firstTime] parameter indicates whether this is the first time
  /// the plugin is being initialized in the current app session.
  ///
  /// Returns a [Future] that completes with a boolean indicating success,
  /// or null if the operation is not applicable.
  Future<bool?> initialize({required bool firstTime}) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Sets the scrollable area rectangle for a given view ID.
  ///
  /// This method communicates the position and size of a scrollable widget
  /// to the native implementation so it can properly handle keyboard
  /// interaction within that area.
  ///
  /// The [id] uniquely identifies the scrollable view, and [rect] contains
  /// the global coordinates and dimensions of the scrollable area.
  Future<void> setScrollableRect(int id, Rect rect) {
    throw UnimplementedError('setScrollableRect() has not been implemented.');
  }

  /// Removes the scrollable area rectangle for a given view ID.
  ///
  /// This method should be called when a scrollable widget is disposed
  /// or no longer needs keyboard interaction handling.
  ///
  /// The [id] identifies which scrollable view to remove.
  Future<void> removeScrollableRect(int id) {
    throw UnimplementedError(
      'removeScrollableRect() has not been implemented.',
    );
  }

  /// Sets the input accessory height for a given view ID.
  ///
  /// This method communicates the height of an input accessory view
  /// to the native implementation for proper keyboard layout calculations.
  ///
  /// The [id] uniquely identifies the input accessory view, and [height]
  /// specifies its height in logical pixels.
  Future<void> setInputAccessoryHeight(int id, double height) {
    throw UnimplementedError(
        'setInputAccessoryHeight() has not been implemented.');
  }

  /// Removes the input accessory height for a given view ID.
  ///
  /// This method should be called when an input accessory view is disposed
  /// or no longer needs to be tracked for keyboard layout.
  ///
  /// The [id] identifies which input accessory view to remove.
  Future<void> removeInputAccessoryHeight(int id) {
    throw UnimplementedError(
      'removeInputAccessoryHeight() has not been implemented.',
    );
  }
}
