import Flutter
import Network
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Lives as long as the app, so the connectivity state is always current.
  private var secureScreen: SecureScreenChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "SecureScreen") else {
      return
    }
    secureScreen = SecureScreenChannel(messenger: registrar.messenger())
  }
}

/// Native side of the dice sandbox (see secure_screen_channel.dart).
private final class SecureScreenChannel: NSObject, FlutterStreamHandler {
  private let methodChannel: FlutterMethodChannel
  private let eventChannel: FlutterEventChannel
  private let pathMonitor = NWPathMonitor()
  private var eventSink: FlutterEventSink?
  private var observers: [NSObjectProtocol] = []
  private var shield: ScreenshotShield?
  private var lastOnline: Bool?

  init(messenger: FlutterBinaryMessenger) {
    methodChannel = FlutterMethodChannel(name: "org.satowiki/secure_screen", binaryMessenger: messenger)
    eventChannel = FlutterEventChannel(name: "org.satowiki/secure_screen/events", binaryMessenger: messenger)
    super.init()

    methodChannel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
    eventChannel.setStreamHandler(self)

    pathMonitor.pathUpdateHandler = { [weak self] path in
      DispatchQueue.main.async {
        self?.connectivityChanged(isOnline: path.status == .satisfied)
      }
    }
    pathMonitor.start(queue: DispatchQueue(label: "org.satowiki.secure_screen.path"))
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "enable":
      enable()
      result(nil)
    case "disable":
      disable()
      result(nil)
    case "isOnline":
      result(pathMonitor.currentPath.status == .satisfied)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func enable() {
    UIApplication.shared.isIdleTimerDisabled = true
    guard shield == nil, let window = keyWindow() else { return }
    shield = ScreenshotShield(window: window)
  }

  private func disable() {
    UIApplication.shared.isIdleTimerDisabled = false
    shield?.remove()
    shield = nil
  }

  private func keyWindow() -> UIWindow? {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
  }

  private func connectivityChanged(isOnline: Bool) {
    guard isOnline != lastOnline else { return }
    lastOnline = isOnline
    eventSink?(isOnline ? "online" : "offline")
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    let center = NotificationCenter.default
    observers = [
      center.addObserver(forName: UIApplication.userDidTakeScreenshotNotification, object: nil, queue: .main) { [weak self] _ in
        self?.eventSink?("screenshotTaken")
      },
      center.addObserver(forName: UIScreen.capturedDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
        self?.eventSink?(UIScreen.main.isCaptured ? "captureStarted" : "captureStopped")
      },
    ]
    // A recording may have started before the sandbox opened; report it now.
    if UIScreen.main.isCaptured {
      events("captureStarted")
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    observers.forEach { NotificationCenter.default.removeObserver($0) }
    observers = []
    eventSink = nil
    return nil
  }
}

/// Keeps the window out of screenshots and recordings.
///
/// iOS blanks the content of a secure text field's rendering layer in
/// captures. The window layer is moved under that layer, and restored when
/// the sandbox closes. This is an undocumented layer technique that has
/// changed between iOS versions: it must be tested on a physical device,
/// since the simulator does not reproduce capture blanking.
private final class ScreenshotShield {
  private let window: UIWindow
  private let field: UITextField
  private let originalSuperlayer: CALayer?
  private let originalIndex: Int?

  init?(window: UIWindow) {
    guard let superlayer = window.layer.superlayer else { return nil }

    let field = UITextField()
    field.isSecureTextEntry = true
    field.isUserInteractionEnabled = false
    window.addSubview(field)
    field.frame = window.bounds
    field.layoutIfNeeded()
    // The secure rendering container is the field's first sublayer.
    guard let secureContainer = field.layer.sublayers?.first else {
      field.removeFromSuperview()
      return nil
    }

    self.window = window
    self.field = field
    originalSuperlayer = superlayer
    originalIndex = superlayer.sublayers?.firstIndex(of: window.layer)

    superlayer.addSublayer(field.layer)
    secureContainer.addSublayer(window.layer)
  }

  /// Puts the window layer back where it was and removes the field.
  func remove() {
    window.layer.removeFromSuperlayer()
    if let superlayer = originalSuperlayer {
      if let index = originalIndex, index <= (superlayer.sublayers?.count ?? 0) {
        superlayer.insertSublayer(window.layer, at: UInt32(index))
      } else {
        superlayer.addSublayer(window.layer)
      }
    }
    field.layer.removeFromSuperlayer()
    field.removeFromSuperview()
  }
}
