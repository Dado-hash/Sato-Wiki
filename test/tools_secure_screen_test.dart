import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/data/secure_screen_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methods = MethodChannel(SecureScreen.methodChannelName);
  const events = EventChannel(SecureScreen.eventChannelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger
      ..setMockMethodCallHandler(methods, null)
      ..setMockStreamHandler(events, null);
  });

  test('uses the agreed channel names', () {
    expect(SecureScreen.methodChannelName, 'org.satowiki/secure_screen');
    expect(SecureScreen.eventChannelName, 'org.satowiki/secure_screen/events');
  });

  test('enable and disable call the matching native methods', () async {
    final calls = <String>[];
    messenger.setMockMethodCallHandler(methods, (call) async {
      calls.add(call.method);
      return null;
    });

    final secure = SecureScreen();
    await secure.enable();
    await secure.disable();

    expect(calls, ['enable', 'disable']);
  });

  test('isOnline returns the native boolean', () async {
    messenger.setMockMethodCallHandler(methods, (call) async {
      expect(call.method, 'isOnline');
      return true;
    });
    expect(await SecureScreen().isOnline(), isTrue);

    messenger.setMockMethodCallHandler(methods, (call) async => false);
    expect(await SecureScreen().isOnline(), isFalse);
  });

  test('isOnline returns null from native as offline', () async {
    messenger.setMockMethodCallHandler(methods, (call) async => null);
    expect(await SecureScreen().isOnline(), isFalse);
  });

  test('isOnline returns false when the native call fails', () async {
    messenger.setMockMethodCallHandler(
      methods,
      (call) async => throw PlatformException(code: 'boom'),
    );
    expect(await SecureScreen().isOnline(), isFalse);
  });

  test('openAirplaneModeSettings returns the native boolean', () async {
    messenger.setMockMethodCallHandler(methods, (call) async {
      expect(call.method, 'openAirplaneModeSettings');
      return true;
    });
    expect(await SecureScreen().openAirplaneModeSettings(), isTrue);

    messenger.setMockMethodCallHandler(methods, (call) async => false);
    expect(await SecureScreen().openAirplaneModeSettings(), isFalse);
  });

  test('openAirplaneModeSettings returns false from native null', () async {
    messenger.setMockMethodCallHandler(methods, (call) async => null);
    expect(await SecureScreen().openAirplaneModeSettings(), isFalse);
  });

  test('openAirplaneModeSettings returns false when the call fails', () async {
    messenger.setMockMethodCallHandler(
      methods,
      (call) async => throw PlatformException(code: 'boom'),
    );
    expect(await SecureScreen().openAirplaneModeSettings(), isFalse);
  });

  test(
    'openAirplaneModeSettings returns false without a native side',
    () async {
      // No mock handler registered: the binding reports MissingPluginException.
      expect(await SecureScreen().openAirplaneModeSettings(), isFalse);
    },
  );

  test('calls degrade when the native plugin is missing', () async {
    // No mock handler registered: the binding reports MissingPluginException.
    final secure = SecureScreen();
    await expectLater(secure.enable(), completes);
    await expectLater(secure.disable(), completes);
    expect(await secure.isOnline(), isFalse);
  });

  test('enable and disable swallow PlatformException', () async {
    messenger.setMockMethodCallHandler(
      methods,
      (call) async => throw PlatformException(code: 'nope'),
    );
    final secure = SecureScreen();
    await expectLater(secure.enable(), completes);
    await expectLater(secure.disable(), completes);
  });

  test('events map native names and ignore unknown ones', () async {
    messenger.setMockStreamHandler(
      events,
      MockStreamHandler.inline(
        onListen: (arguments, sink) {
          sink
            ..success('screenshotTaken')
            ..success('somethingElse')
            ..success('captureStarted')
            ..success('captureStopped')
            ..success('online')
            ..success('offline');
          sink.endOfStream();
        },
      ),
    );

    final received = await SecureScreen().events.toList();

    expect(received, [
      SecureScreenEvent.screenshotTaken,
      SecureScreenEvent.captureStarted,
      SecureScreenEvent.captureStopped,
      SecureScreenEvent.wentOnline,
      SecureScreenEvent.wentOffline,
    ]);
  });

  test('events stay silent when the native event channel is missing', () async {
    // Without a native side, the platform stream reports the missing plugin
    // through FlutterError and never completes: the subscriber just gets nothing.
    final previousOnError = FlutterError.onError;
    final reported = <FlutterErrorDetails>[];
    FlutterError.onError = reported.add;
    addTearDown(() => FlutterError.onError = previousOnError);

    final received = <SecureScreenEvent>[];
    final subscription = SecureScreen().events.listen(received.add);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await subscription.cancel();

    expect(received, isEmpty);
  });
}
