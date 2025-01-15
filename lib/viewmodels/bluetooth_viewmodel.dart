import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class BluetoothViewModel extends ChangeNotifier {
  FlutterBluePlus flutterBlue = FlutterBluePlus();  // Instanciamos sin usar `instance`
  bool isScanning = false;
  List<BluetoothDevice> devices = [];
  bool isLoading = false;

  bool isBluetoothGranted = false;
  bool isBluetoothScanGranted = false;
  bool isBluetoothConnectGranted = false;
  bool isLocationGranted = false;

  // Verificación de permisos
  Future<void> checkPermissions() async {
    var status = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    // Actualizamos los estados de los permisos
    isBluetoothGranted = status[Permission.bluetooth] == PermissionStatus.granted;
    isBluetoothScanGranted = status[Permission.bluetoothScan] == PermissionStatus.granted;
    isBluetoothConnectGranted = status[Permission.bluetoothConnect] == PermissionStatus.granted;
    isLocationGranted = status[Permission.location] == PermissionStatus.granted;

    notifyListeners();
  }

  // Verificar el estado de Bluetooth
  Future<bool> _checkBluetoothStatus() async {
    BluetoothAdapterState bluetoothState = await FlutterBluePlus.adapterState.first;
    if (bluetoothState == BluetoothAdapterState.off) {
      print('Bluetooth is off, trying to turn it on...');
      await FlutterBluePlus.turnOn(); // Intentar encender el Bluetooth
      await Future.delayed(const Duration(seconds: 2));
      bluetoothState = await FlutterBluePlus.adapterState.first;  // Reconsultamos el estado
    }
    return bluetoothState == BluetoothAdapterState.on;
  }

  // Iniciar el escaneo
  Future<void> startScanning() async {
    // Verificar Bluetooth y permisos antes de iniciar el escaneo
    if (!isBluetoothGranted || !isBluetoothScanGranted || !isBluetoothConnectGranted || !isLocationGranted) {
      print('Some permissions are missing');
      return;
    }

    isLoading = true;
    notifyListeners();

    bool bluetoothReady = await _checkBluetoothStatus();
    if (!bluetoothReady) {
      print('Bluetooth is not ready');
      isLoading = false;
      notifyListeners();
      return;
    }

    isScanning = true;
    devices.clear();  // Limpiar la lista de dispositivos antes de empezar
    notifyListeners();

    // Iniciar escaneo
    print('Starting Bluetooth scan...');
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 40));

    FlutterBluePlus.scanResults.listen((results) {
      if (results.isNotEmpty) {
        print("Found devices: ${results.length}");
        devices = results.map((result) => result.device).toList();
      } else {
        print("No devices found.");
      }
      isScanning = false;
      isLoading = false;  // Detener el indicador de carga
      notifyListeners();
    });

    // Detener escaneo si se excede el tiempo
    FlutterBluePlus.isScanning.listen((isScanningActive) {
      if (!isScanningActive) {
        print("Scan stopped unexpectedly.");
        isScanning = false;
        isLoading = false;
        notifyListeners();
      }
    });
  }
}