import 'package:bluetooth_pruebas/viewmodels/bluetooth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class DeviceListWidget extends StatelessWidget {
  const DeviceListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bluetoothViewModel = context.watch<BluetoothViewModel>();

    return Column(
      children: [
        const SizedBox(height: 16),
        bluetoothViewModel.isScanning
            ? const CircularProgressIndicator()
            : bluetoothViewModel.devices.isEmpty
                ? const Text(
                    "No devices found",
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: bluetoothViewModel.devices.length,
                      itemBuilder: (context, index) {
                        final device = bluetoothViewModel.devices[index];
                        return ListTile(
                          leading: const Icon(Icons.bluetooth),
                          title: Text(device.name.isNotEmpty
                              ? device.name
                              : "Unknown Device"),
                          subtitle: Text(device.id.toString()),
                          trailing: IconButton(
                            icon: const Icon(Icons.link),
                            onPressed: () {
                              bluetoothViewModel.connectToDevice(device);
                            },
                          ),
                        );
                      },
                    ),
                  ),
      ],
    );
  }
}
