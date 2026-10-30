import 'package:flutter/services.dart';

/// Events from the native sandbox guard.
enum SecureScreenEvent {
  screenshotTaken,
  captureStarted,
  captureStopped,
  wentOnline,
  wentOffline,
}

/// Native guard for the dice sandbox: blocks screenshots and recording where
/// the platform allows it, keeps the screen on, reports network state.
///
/// Every call degrades quietly when the native side is missing (tests,
/// desktop): enable and disable do nothing, [isOnline] and
/// [openAirplaneModeSettings] return false, [isAirplaneModeOn] returns null
/// and [events] is empty.
class SecureScreen {
  /// Creates the guard. The channels can be replaced in tests.
  SecureScreen({MethodChannel? methods, EventChannel? events})
    : _methods = methods ?? const MethodChannel(methodChannelName),
      _events = events ?? const EventChannel(eventChannelName);

  /// Method channel used for enable, disable, isOnline, isAirplaneModeOn and
  /// openAirplaneModeSettings.
  static const methodChannelName = 'org.satowiki/secure_screen';

  /// Event channel used for screenshot, capture and connectivity events.
  static const eventChannelName = 'org.satowiki/secure_screen/events';

  static const _eventNames = <String, SecureScreenEvent>{
    'screenshotTaken': SecureScreenEvent.screenshotTaken,
    'captureStarted': SecureScreenEvent.captureStarted,
    'captureStopped': SecureScreenEvent.captureStopped,
    'online': SecureScreenEvent.wentOnline,
    'offline': SecureScreenEvent.wentOffline,
  };

  final MethodChannel _methods;
  final EventChannel _events;

  /// Turns on the screenshot shield and keeps the screen awake.
  Future<void> enable() => _invokeVoid('enable');

  /// Turns the shield off and lets the screen sleep again.
  Future<void> disable() => _invokeVoid('disable');

  /// Whether the device currently has an internet connection.
  /// Returns false when the native side is missing or fails.
  Future<bool> isOnline() async {
    try {
      return await _methods.invokeMethod<bool>('isOnline') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Whether airplane mode is on. Null when the platform cannot tell (iOS has
  /// no public API for it) or the native side is missing or fails.
  ///
  /// Airplane mode can be on while Wi-Fi is still connected: both iOS and
  /// Android remember Wi-Fi turned back on in airplane mode. [isOnline] is the
  /// value that says whether data can leave.
  Future<bool?> isAirplaneModeOn() async {
    try {
      return await _methods.invokeMethod<bool>('isAirplaneModeOn');
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  /// Opens the system airplane mode settings. Returns true when a settings
  /// screen was opened. On iOS there is no such screen, so this returns false.
  Future<bool> openAirplaneModeSettings() async {
    try {
      return await _methods.invokeMethod<bool>('openAirplaneModeSettings') ??
          false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Guard events. Unknown names from the native side are ignored.
  ///
  /// The stream is built once per instance and shared: each call to
  /// `receiveBroadcastStream` replaces the previous native listener, so the
  /// checklist and the sandbox must listen to the same stream.
  late final Stream<SecureScreenEvent> events = _buildEvents();

  Stream<SecureScreenEvent> _buildEvents() {
    final Stream<Object?> raw;
    try {
      raw = _events.receiveBroadcastStream();
    } on MissingPluginException {
      return const Stream<SecureScreenEvent>.empty();
    }
    return raw
        .expand((Object? name) {
          final event = _eventNames[name];
          return event == null ? const <SecureScreenEvent>[] : [event];
        })
        .handleError(
          (Object error, StackTrace stack) {
            // A missing or failing native side ends the stream without
            // reporting anything: the sandbox still works on its own.
          },
          test: (error) =>
              error is MissingPluginException || error is PlatformException,
        );
  }

  Future<void> _invokeVoid(String method) async {
    try {
      await _methods.invokeMethod<void>(method);
    } on MissingPluginException {
      // No native guard on this platform: nothing to do.
    } on PlatformException {
      // The native guard failed; the Dart side keeps working.
    }
  }
}
