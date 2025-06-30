import 'package:flutter/material.dart';
import 'package:common/model/device.dart';
import 'package:localsend_app/provider/network/nearby_devices_provider.dart';
import 'package:localsend_app/provider/favorites_provider.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:localsend_app/pages/chat_page.dart';

class DevicesPage extends ConsumerWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context, RefenaContainer ref) {
    final nearbyDevicesState = ref.watch(nearbyDevicesProvider);
    final favoriteDevices = ref.watch(favoritesProvider);

    // Combine online devices and favorite devices, ensuring uniqueness by fingerprint
    final allDevices = <String, Device>{};
    for (final device in nearbyDevicesState.devices.values) {
      allDevices[device.fingerprint] = device;
    }
    for (final favDevice in favoriteDevices) {
      if (!allDevices.containsKey(favDevice.fingerprint)) {
        // Create a dummy Device object for offline favorites
        allDevices[favDevice.fingerprint] = Device(
          ip: favDevice.ip,
          version: 'unknown', // Placeholder
          port: favDevice.port,
          https: false, // Placeholder
          fingerprint: favDevice.fingerprint,
          alias: favDevice.alias,
          deviceModel: 'unknown', // Placeholder
          deviceType: DeviceType.desktop, // Placeholder
          download: false, // Placeholder
        );
      }
    }

    final sortedDevices = allDevices.values.toList()
      ..sort((a, b) {
        final aOnline = nearbyDevicesState.devices.containsKey(a.ip);
        final bOnline = nearbyDevicesState.devices.containsKey(b.ip);
        if (aOnline && !bOnline) return -1; // Online devices first
        if (!aOnline && bOnline) return 1;
        return a.alias.compareTo(b.alias); // Then by alias
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
      ),
      body: ListView.builder(
        itemCount: sortedDevices.length,
        itemBuilder: (context, index) {
          final device = sortedDevices[index];
          final isOnline = nearbyDevicesState.devices.containsKey(device.ip);

          return Opacity(
            opacity: isOnline ? 1.0 : 0.5, // Gray out if offline
            child: ListTile(
              leading: Stack(
                children: [
                  Icon(Icons.person), // Placeholder for device icon
                  if (isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.red, // Red dot for online
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(device.alias),
              subtitle: Text(device.ip),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatPage(device: device),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
