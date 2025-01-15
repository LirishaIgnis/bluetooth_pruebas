import 'package:bluetooth_pruebas/viewmodels/bluetooth_viewmodel.dart';
import 'package:bluetooth_pruebas/widgets/device_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bluetoothViewModel = Provider.of<BluetoothViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Scanner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Permisos y Estado de Bluetooth',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<bool>(
              future: bluetoothViewModel.requestPermissions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData && snapshot.data!) {
                  return const Icon(Icons.check, color: Colors.green);
                } else {
                  return const Icon(Icons.close, color: Colors.red);
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: bluetoothViewModel.startScanning,
              child: bluetoothViewModel.isScanning
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Buscar dispositivos'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Dispositivos encontrados:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: bluetoothViewModel.scanResults.length,
                itemBuilder: (context, index) {
                  final result = bluetoothViewModel.scanResults[index];
                  return ListTile(
                    title: Text(result.device.name.isNotEmpty
                        ? result.device.name
                        : 'Dispositivo sin nombre'),
                    subtitle: Text(result.device.remoteId.toString()),
                    trailing: bluetoothViewModel.isConnecting
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () =>
                                bluetoothViewModel.connectToDevice(result.device),
                            child: const Text('Conectar'),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}