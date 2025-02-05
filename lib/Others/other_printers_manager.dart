import 'dart:async';
import 'dart:developer';

import 'package:flutter_thermal_printer/Others/other_ble_manager.dart';
import 'package:flutter_thermal_printer/Others/other_blt_manager.dart';
import 'package:flutter_thermal_printer/Others/other_tcp_manager.dart';
import 'package:flutter_thermal_printer/Others/other_usb_manager.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:collection/collection.dart';

class OtherPrinterManager {
  OtherPrinterManager._privateConstructor();

  static OtherPrinterManager? _instance;

  static OtherPrinterManager get instance {
    _instance ??= OtherPrinterManager._privateConstructor();
    return _instance!;
  }

  final StreamController<List<Printer>> _devicesStreamController = StreamController<List<Printer>>.broadcast();

  Stream<List<Printer>> get devicesStream => _devicesStreamController.stream;

  final List<Printer> _devices = [];

  // Stop scanning for BLE devices
  Future<void> stopScan({
    bool stopBle = true,
    bool stopBluetooth = true,
    bool stopUsb = true,
    bool stopTcp = true,
  }) async {
    try {
      if (stopBle) {
        await OtherBleManager().stopScan();
      }
      if (stopBluetooth) {
        await OtherBltManager().stopScan();
      }
      if (stopUsb) {
        await OtherUsbManager().stopScan();
      }
      if (stopTcp) {
        await OtherTcpManager().stopScan();
      }
    } catch (e) {
      log('Failed to stop scanning for devices $e');
    }
  }

  Future<bool> testConnect(Printer device) async {
    if (device.connectionType == ConnectionType.TCP) {
      return OtherTcpManager().testConnect(device);
    } else if (device.connectionType == ConnectionType.USB) {
      return OtherUsbManager().testConnect(device);
    } else if (device.connectionType == ConnectionType.BLE) {
      return OtherBleManager().testConnect(device);
    } else if (device.connectionType == ConnectionType.BLUETOOTH) {
      return OtherBltManager().testConnect(device);
    }
    return false;
  }

  Future<bool> isConnected(Printer device) async {
    if (device.connectionType == ConnectionType.TCP) {
      return OtherTcpManager().isConnected(device);
    } else if (device.connectionType == ConnectionType.USB) {
      return OtherUsbManager().isConnected(device);
    } else if (device.connectionType == ConnectionType.BLE) {
      return OtherBleManager().isConnected(device);
    } else if (device.connectionType == ConnectionType.BLUETOOTH) {
      return OtherBltManager().isConnected(device);
    }
    return false;
  }

  Future<void> printData(
    Printer printer,
    List<int> bytes, {
    bool longData = false,
  }) async {
    if (printer.connectionType == ConnectionType.TCP) {
      await OtherTcpManager().print(printer, bytes, longData: longData);
    } else if (printer.connectionType == ConnectionType.USB) {
      await OtherUsbManager().print(printer, bytes, longData: longData);
    } else if (printer.connectionType == ConnectionType.BLE) {
      await OtherBleManager().print(printer, bytes, longData: longData);
    } else if (printer.connectionType == ConnectionType.BLUETOOTH) {
      await OtherBltManager().print(printer, bytes, longData: longData);
    }
  }

  // Get Printers from BT and USB
  Future<void> getPrinters({
    List<ConnectionType> connectionTypes = const [
      ConnectionType.BLE,
      ConnectionType.BLUETOOTH,
      ConnectionType.USB,
      ConnectionType.TCP,
    ],
    bool androidUsesFineLocation = false,
  }) async {
    this._devices.clear();
    if (connectionTypes.isEmpty) {
      throw Exception('No connection type provided');
    }

    if (connectionTypes.contains(ConnectionType.TCP)) {
      await OtherTcpManager().startScan(callback: (printers) {
        printers.forEach((printer) {
          this._updateOrAddPrinter(printer);
        });
      });
    }

    if (connectionTypes.contains(ConnectionType.USB)) {
      await OtherUsbManager().startScan(callback: (printers) {
        printers.forEach((printer) {
          this._updateOrAddPrinter(printer);
        });
      });
    }

    if (connectionTypes.contains(ConnectionType.BLUETOOTH)) {
      await OtherBltManager().startScan(callback: (printers) {
        printers.forEach((printer) {
          this._updateOrAddPrinter(printer);
        });
      });
    }

    await Future.delayed(const Duration(seconds: 1));

    if (connectionTypes.contains(ConnectionType.BLE)) {
      await OtherBleManager().startScan(callback: (printers) {
        printers.forEach((printer) {
          this._updateOrAddPrinter(printer);
        });
      });
    }
  }

  void _updateOrAddPrinter(Printer printer) {
    if (printer.name == null || printer.name == '') {
      return;
    }
    Printer? find =
        this._devices.firstWhereOrNull((device) => device.toString() == printer.toString() && device.connectionType == printer.connectionType);
    if (find == null) {
      this._devices.add(printer);
    }
    this._devicesStreamController.add(this._devices);
  }
}
