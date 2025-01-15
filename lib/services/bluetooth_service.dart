import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  // Eliminamos el uso de `instance`.

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  void startScan({Duration timeout = const Duration(seconds: 5)}) {
    FlutterBluePlus.startScan(timeout: timeout);
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
  }
}

