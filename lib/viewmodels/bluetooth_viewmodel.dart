import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class BluetoothViewModel extends ChangeNotifier {
  FlutterBluePlus flutterBlue = FlutterBluePlus();
  bool isScanning = false;
  bool isConnecting = false;
  List<ScanResult> scanResults = [];
  BluetoothDevice? connectedDevice;

  get devices => null;

  // Solicitar y verificar permisos
  Future<bool> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.location
  ].request();

  // Verificar si todos los permisos fueron concedidos
  return statuses.values.every((status) => status.isGranted);
}

  // Verificar estado del Bluetooth
  Future<bool> checkBluetoothStatus() async {
    BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
    if (state == BluetoothAdapterState.off) {
      await FlutterBluePlus.turnOn();
      await Future.delayed(const Duration(seconds: 2));
      state = await FlutterBluePlus.adapterState.first;
    }
    return state == BluetoothAdapterState.on;
  }

  // Iniciar escaneo
  Future<void> startScanning() async {
    if (!await requestPermissions()) {
      print("Permisos no concedidos.");
      return;
    }

    if (!await checkBluetoothStatus()) {
      print("Bluetooth no está encendido.");
      return;
    }

    isScanning = true;
    scanResults.clear();
    notifyListeners();

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 30));
    FlutterBluePlus.scanResults.listen((results) {
      scanResults = results;
      notifyListeners();
    }).onError((e) {
      print("Error al escanear: $e");
    });

    await FlutterBluePlus.isScanning.where((scanning) => !scanning).first;
    isScanning = false;

    if (scanResults.isEmpty) {
      print("No se encontraron dispositivos.");
    }
    notifyListeners();
  }

  // Conectar a un dispositivo
  Future<void> connectToDevice(BluetoothDevice device) async {
    isConnecting = true;
    notifyListeners();

    try {
      await device.connect();
      connectedDevice = device;
      print("Conectado a ${device.name}.");
    } catch (e) {
      print("Error al conectar: $e");
    } finally {
      isConnecting = false;
      notifyListeners();
    }
  }

  // Desconectar dispositivo
  Future<void> disconnectDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      connectedDevice = null;
      print("Dispositivo desconectado.");
      notifyListeners();
    }
  }
}