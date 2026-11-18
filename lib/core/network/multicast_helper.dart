
import 'package:flutter/services.dart';

class MulticastHelper {
  static const MethodChannel _channel =
      MethodChannel('com.example.mytooth/multicast');

  static Future<void> acquire() async {
    await _channel.invokeMethod('acquireMulticastLock');
  }

  static Future<void> release() async {
    await _channel.invokeMethod('releaseMulticastLock');
  }
}
