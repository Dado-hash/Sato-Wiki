import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:sato_wiki/src/features/tools/data/dice_detector.dart';
import 'package:sato_wiki/src/features/tools/data/secure_screen_channel.dart';
import 'package:sato_wiki/src/features/tools/domain/dice_detection.dart';

/// Camera reader that never touches a camera. The test pushes the frames.
final class FakeDiceDetector implements DiceDetector {
  FakeDiceDetector({this.available = true});

  /// What [isAvailable] answers.
  bool available;

  /// Number of [start] calls.
  int starts = 0;

  /// Number of [stop] calls.
  int stops = 0;

  /// Number of [dispose] calls.
  int disposes = 0;

  final _frames = StreamController<List<DetectedDie>>.broadcast();

  /// True while the sandbox listens to the frames.
  bool get listening => _frames.hasListener;

  /// Sends one frame of detections to the sandbox.
  void push(List<DetectedDie> frame) => _frames.add(frame);

  /// Closes the frame stream. Call from tearDown.
  Future<void> close() => _frames.close();

  @override
  Future<bool> isAvailable() async => available;

  @override
  Stream<List<DetectedDie>> get detections => _frames.stream;

  @override
  Future<void> start() async => starts++;

  @override
  Future<void> stop() async => stops++;

  @override
  Future<void> dispose() async => disposes++;

  @override
  Widget? buildPreview() {
    return const ColoredBox(color: Color(0xFF101010));
  }
}

/// Native guard double: counts enable and disable, and emits events on demand.
final class FakeSecureScreen implements SecureScreen {
  FakeSecureScreen({
    this.online = false,
    this.airplaneMode,
    this.canOpenSettings = true,
  });

  /// What [isOnline] answers.
  bool online;

  /// What [isAirplaneModeOn] answers. Null means the platform cannot tell.
  bool? airplaneMode;

  /// What [openAirplaneModeSettings] answers.
  bool canOpenSettings;

  /// Number of [enable] calls.
  int enables = 0;

  /// Number of [disable] calls.
  int disables = 0;

  /// Number of [openAirplaneModeSettings] calls.
  int settingsOpens = 0;

  final _events = StreamController<SecureScreenEvent>.broadcast();

  /// Emits a native event to the sandbox.
  void emit(SecureScreenEvent event) => _events.add(event);

  /// Closes the event stream. Call from tearDown.
  Future<void> close() => _events.close();

  @override
  Future<void> enable() async => enables++;

  @override
  Future<void> disable() async => disables++;

  @override
  Future<bool> isOnline() async => online;

  @override
  Future<bool?> isAirplaneModeOn() async => airplaneMode;

  @override
  Future<bool> openAirplaneModeSettings() async {
    settingsOpens++;
    return canOpenSettings;
  }

  @override
  Stream<SecureScreenEvent> get events => _events.stream;
}
