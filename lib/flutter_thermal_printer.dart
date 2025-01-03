import 'dart:async';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_thermal_printer/Windows/window_printer_manager.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'Others/other_printers_manager.dart';
export 'package:flutter_blue_plus/flutter_blue_plus.dart' show BluetoothDevice, BluetoothConnectionState;

class FlutterThermalPrinter {
  FlutterThermalPrinter._();

  static FlutterThermalPrinter? _instance;

  static FlutterThermalPrinter get instance {
    FlutterBluePlus.setLogLevel(LogLevel.debug);
    _instance ??= FlutterThermalPrinter._();
    return _instance!;
  }

  Stream<List<Printer>> get devicesStream {
    if (Platform.isWindows) {
      return WindowPrinterManager.instance.devicesStream;
    } else {
      return OtherPrinterManager.instance.devicesStream;
    }
  }

  Future<bool> testConnect(Printer device) async {
    if (Platform.isWindows) {
      return await WindowPrinterManager.instance.connect(device);
    } else {
      return await OtherPrinterManager.instance.testConnect(device);
    }
  }

  Future<bool> isConnected(Printer device) async {
    if (Platform.isAndroid) {
      return await OtherPrinterManager.instance.isConnected(device);
    }
    return false;
  }

  Future<void> print(
    Printer device,
    List<int> bytes, {
    bool longData = false,
  }) async {
    if (Platform.isWindows) {
      return await WindowPrinterManager.instance.printData(
        device,
        bytes,
        longData: longData,
      );
    } else {
      return await OtherPrinterManager.instance.printData(
        device,
        bytes,
        longData: longData,
      );
    }
  }

  Future<void> startScan({
    Duration refreshDuration = const Duration(seconds: 2),
    List<ConnectionType> connectionTypes = const [ConnectionType.USB, ConnectionType.BLE, ConnectionType.TCP, ConnectionType.BLUETOOTH],
    bool androidUsesFineLocation = false,
  }) async {
    if (Platform.isWindows) {
      WindowPrinterManager.instance.getPrinters(
        refreshDuration: refreshDuration,
        connectionTypes: connectionTypes,
      );
    } else {
      OtherPrinterManager.instance.getPrinters(
        connectionTypes: connectionTypes,
        androidUsesFineLocation: androidUsesFineLocation,
      );
    }
  }

  Future<void> stopScan() async {
    if (Platform.isWindows) {
      WindowPrinterManager.instance.stopscan();
    } else {
      OtherPrinterManager.instance.stopScan();
    }
  }
}
