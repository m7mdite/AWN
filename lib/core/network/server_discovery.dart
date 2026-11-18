
import 'package:multicast_dns/multicast_dns.dart';
import 'multicast_helper.dart';

class ServerDiscovery {
  static Future testDiscovery() async {
    final client = MDnsClient();
    var lockAcquired = false;

    try {
      await MulticastHelper.acquire();
      lockAcquired = true;

      await client.start();

      print('MDNS TEST: Started');

      await for (final PtrResourceRecord ptr
          in client.lookup<PtrResourceRecord>(
        ResourceRecordQuery.serverPointer('_http._tcp.local'),
      ).timeout(const Duration(seconds: 10))) {
        print('MDNS TEST PTR: ${ptr.domainName}');
      }

      print('MDNS TEST: Search completed');
    } catch (e, st) {
      print('MDNS TEST ERROR: $e');
      print(st);
    } finally {
      client.stop();

      if (lockAcquired) {
        await MulticastHelper.release();
      }
    }
  }
}
