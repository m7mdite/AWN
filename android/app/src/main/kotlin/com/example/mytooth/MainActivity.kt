
package com.example.mytooth

import android.content.Context
import android.net.wifi.WifiManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "com.example.mytooth/multicast"
    private var multicastLock: WifiManager.MulticastLock? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "acquireMulticastLock" -> {
                    try {
                        if (multicastLock == null) {
                            val wifiManager =
                                applicationContext.getSystemService(
                                    Context.WIFI_SERVICE
                                ) as WifiManager

                            multicastLock =
                                wifiManager.createMulticastLock("FlutterMDNS")

                            multicastLock?.setReferenceCounted(false)
                        }

                        if (multicastLock?.isHeld != true) {
                            multicastLock?.acquire()
                        }

                        result.success(true)
                    } catch (e: Exception) {
                        result.error(
                            "MULTICAST_LOCK_ERROR",
                            e.message,
                            null
                        )
                    }
                }

                "releaseMulticastLock" -> {
                    try {
                        if (multicastLock?.isHeld == true) {
                            multicastLock?.release()
                        }

                        result.success(true)
                    } catch (e: Exception) {
                        result.error(
                            "MULTICAST_RELEASE_ERROR",
                            e.message,
                            null
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        if (multicastLock?.isHeld == true) {
            multicastLock?.release()
        }

        multicastLock = null
        super.onDestroy()
    }
}
