package org.satowiki.sato_wiki

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/// Hosts the Flutter UI and the native guard used by the dice sandbox.
class MainActivity : FlutterActivity() {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var eventSink: EventChannel.EventSink? = null
    private var networkCallback: ConnectivityManager.NetworkCallback? = null
    private var screenCaptureCallback: Activity.ScreenCaptureCallback? = null
    /// Networks that currently have INTERNET capability. Only touched on the main thread.
    private val internetNetworks = mutableSetOf<Network>()
    /// Last connectivity state sent to Dart, used to skip duplicate events.
    private var lastOnline: Boolean? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        MethodChannel(messenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enable" -> runOnUiThread {
                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE or WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    result.success(null)
                }
                "disable" -> runOnUiThread {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE or WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    result.success(null)
                }
                "isOnline" -> result.success(isOnline())
                "isAirplaneModeOn" -> result.success(isAirplaneModeOn())
                "openAirplaneModeSettings" -> result.success(openAirplaneModeSettings())
                else -> result.notImplemented()
            }
        }

        EventChannel(messenger, EVENT_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                eventSink = events
                registerNetworkCallback()
                startScreenCaptureDetection()
                // Report the current state once, so a new listener does not wait for a change.
                mainHandler.post { reportConnectivity(isOnline()) }
            }

            override fun onCancel(arguments: Any?) {
                stopScreenCaptureDetection()
                unregisterNetworkCallback()
                eventSink = null
            }
        })
    }

    override fun onDestroy() {
        stopScreenCaptureDetection()
        unregisterNetworkCallback()
        eventSink = null
        super.onDestroy()
    }

    /// Sends an event to Dart on the main thread, if a listener is attached.
    private fun send(name: String) {
        mainHandler.post { eventSink?.success(name) }
    }

    private fun isOnline(): Boolean {
        val connectivity = getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager ?: return false
        val network = connectivity.activeNetwork ?: return false
        val capabilities = connectivity.getNetworkCapabilities(network) ?: return false
        return capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
    }

    /// Reads the airplane mode switch from the system settings.
    private fun isAirplaneModeOn(): Boolean {
        return Settings.Global.getInt(contentResolver, Settings.Global.AIRPLANE_MODE_ON, 0) != 0
    }

    /// Opens the airplane mode settings, or the wireless settings when the
    /// device has no such screen. Returns false when neither can be opened.
    private fun openAirplaneModeSettings(): Boolean {
        return try {
            startActivity(Intent(Settings.ACTION_AIRPLANE_MODE_SETTINGS))
            true
        } catch (_: ActivityNotFoundException) {
            try {
                startActivity(Intent(Settings.ACTION_WIRELESS_SETTINGS))
                true
            } catch (_: ActivityNotFoundException) {
                false
            }
        }
    }

    private fun registerNetworkCallback() {
        if (networkCallback != null) return
        val connectivity = getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager ?: return
        // Callbacks run on a ConnectivityThread: hop to the main thread before touching state.
        val callback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                mainHandler.post { networkChanged(network, available = true) }
            }

            override fun onLost(network: Network) {
                mainHandler.post { networkChanged(network, available = false) }
            }
        }
        val request = NetworkRequest.Builder()
            .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .build()
        try {
            connectivity.registerNetworkCallback(request, callback)
            networkCallback = callback
        } catch (_: SecurityException) {
            // ACCESS_NETWORK_STATE missing: connectivity events are simply not reported.
        }
    }

    private fun unregisterNetworkCallback() {
        internetNetworks.clear()
        lastOnline = null
        val callback = networkCallback ?: return
        networkCallback = null
        val connectivity = getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager ?: return
        try {
            connectivity.unregisterNetworkCallback(callback)
        } catch (_: IllegalArgumentException) {
            // Already unregistered.
        }
    }

    /// Adds or removes one network, then reports the overall state if it changed.
    /// Runs on the main thread. Ignored after the callback has been unregistered.
    private fun networkChanged(network: Network, available: Boolean) {
        if (networkCallback == null) return
        if (available) internetNetworks.add(network) else internetNetworks.remove(network)
        reportConnectivity(internetNetworks.isNotEmpty())
    }

    /// Sends "online" or "offline" to Dart, but only when the state differs from the last one sent.
    private fun reportConnectivity(online: Boolean) {
        if (online == lastOnline) return
        lastOnline = online
        eventSink?.success(if (online) "online" else "offline")
    }

    /// Screenshot detection exists from Android 14 (API 34). Older versions only get FLAG_SECURE.
    private fun startScreenCaptureDetection() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE || screenCaptureCallback != null) return
        val callback = Activity.ScreenCaptureCallback { send("screenshotTaken") }
        try {
            registerScreenCaptureCallback(mainExecutor, callback)
            screenCaptureCallback = callback
        } catch (_: SecurityException) {
            // DETECT_SCREEN_CAPTURE missing: screenshot events are not reported.
        }
    }

    private fun stopScreenCaptureDetection() {
        val callback = screenCaptureCallback ?: return
        screenCaptureCallback = null
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            unregisterScreenCaptureCallback(callback)
        }
    }

    private companion object {
        const val METHOD_CHANNEL = "org.satowiki/secure_screen"
        const val EVENT_CHANNEL = "org.satowiki/secure_screen/events"
    }
}
