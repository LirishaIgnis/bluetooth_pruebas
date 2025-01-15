import 'package:bluetooth_pruebas/viewmodels/bluetooth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isBluetoothOn = false;
  bool isScanning = false;
  List<BluetoothDevice> devices = [];
  Map<Permission, bool> permissionsStatus = {
    Permission.bluetooth: false,
    Permission.bluetoothScan: false,
    Permission.bluetoothConnect: false,
    Permission.location: false,
  };

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndBluetooth();
  }

  // Verifica permisos y estado del Bluetooth
  Future<void> _checkPermissionsAndBluetooth() async {
    await _checkPermissions();
    await _checkBluetoothStatus();
  }

  // Verifica los permisos uno por uno
  Future<void> _checkPermissions() async {
    for (var permission in permissionsStatus.keys) {
      permissionsStatus[permission] = await permission.isGranted;
      if (!permissionsStatus[permission]!) {
        await permission.request();
        permissionsStatus[permission] = await permission.isGranted;
      }
    }
    setState(() {});
  }

  // Verifica y enciende el Bluetooth si es necesario
  Future<void> _checkBluetoothStatus() async {
    BluetoothAdapterState bluetoothState = await FlutterBluePlus.adapterState.first;
    if (bluetoothState == BluetoothAdapterState.off) {
      await FlutterBluePlus.turnOn();
      await Future.delayed(Duration(seconds: 2));
      bluetoothState = await FlutterBluePlus.adapterState.first;
    }
    setState(() {
      isBluetoothOn = bluetoothState == BluetoothAdapterState.on;
    });
  }

  // Inicia el escaneo de dispositivos
  Future<void> _startScan() async {
    if (!isBluetoothOn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bluetooth is not enabled.')),
      );
      return;
    }

    setState(() {
      isScanning = true;
      devices.clear();
    });

    FlutterBluePlus.onScanResults.listen((results) {
      if (results.isNotEmpty) {
        setState(() {
          devices = results.map((result) => result.device).toList();
        });
      }
    });

    await FlutterBluePlus.startScan(timeout: Duration(seconds: 30));

    // Verifica si no se encontraron dispositivos
    if (devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No devices found during the scan.')),
      );
    }

    setState(() {
      isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Scanner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Permissions Status:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...permissionsStatus.entries.map((entry) => ListTile(
                  title: Text(entry.key.toString().split('.').last),
                  trailing: Icon(
                    entry.value ? Icons.check_circle : Icons.error,
                    color: entry.value ? Colors.green : Colors.red,
                  ),
                )),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bluetooth:'),
                Icon(
                  isBluetoothOn ? Icons.check_circle : Icons.error,
                  color: isBluetoothOn ? Colors.green : Colors.red,
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isScanning ? null : _startScan,
              child: Text(isScanning ? 'Scanning...' : 'Start Scan'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: devices.isEmpty
                  ? Center(child: Text('No devices found.'))
                  : ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(devices[index].name.isEmpty
                              ? 'Unknown Device'
                              : devices[index].name),
                          subtitle: Text(devices[index].id.toString()),
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