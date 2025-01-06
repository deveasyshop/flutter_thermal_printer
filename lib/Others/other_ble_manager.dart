import 'dart:async';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_thermal_printer/Others/other_interface.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';

class OtherBleManager implements OtherInterface {
  static final OtherBleManager _instance = OtherBleManager._internal();

  factory OtherBleManager() {
    return _instance;
  }

  StreamSubscription? _bleSubscription;

  OtherBleManager._internal();

  @override
  startScan({required Function(List<Printer> printers) callback}) async {
    try {
      _bleSubscription?.cancel();

      if (Platform.isAndroid && FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
        await FlutterBluePlus.turnOn();
      }

      await FlutterBluePlus.stopScan();
      await FlutterBluePlus.startScan();

      // Get system devices
      List<Printer> systemPrinters = (await FlutterBluePlus.systemDevices([]))
          .map((device) => Printer(
                address: device.remoteId.str,
                name: device.platformName,
                connectionType: ConnectionType.BLE,
              ))
          .toList();
      callback(systemPrinters);

      // Get bonded devices (Android only)
      if (Platform.isAndroid) {
        List<Printer> bondedPrinters = (await FlutterBluePlus.bondedDevices)
            .map((device) => Printer(
                  address: device.remoteId.str,
                  name: device.platformName,
                  connectionType: ConnectionType.BLE,
                ))
            .toList();
        callback(bondedPrinters);
      }

      // Listen to scan results
      _bleSubscription = FlutterBluePlus.scanResults.listen((result) {
        List<Printer> printers = result.map((e) {
          return Printer(
            address: e.device.remoteId.str,
            name: e.device.platformName,
            connectionType: ConnectionType.BLE,
          );
        }).toList();
        callback(printers);
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  stopScan() async {
    await _bleSubscription?.cancel();
    await FlutterBluePlus.stopScan();
  }

  @override
  Future print(Printer printer, List<int> bytes, {bool longData = false}) async {
    try {
      final device = BluetoothDevice.fromId(printer.address!);
      if (!device.isConnected) {
        await device.connect();
      }
      final services =
          (await device.discoverServices()).skipWhile((value) => value.characteristics.where((element) => element.properties.write).isEmpty);
      BluetoothCharacteristic? writecharacteristic;
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            writecharacteristic = characteristic;
            break;
          }
        }
      }
      if (writecharacteristic == null) {
        throw Exception("Fail to print on BLE");
      }
      if (longData) {
        int mtu = (await device.mtu.first) - 30;
        final numberOfTimes = bytes.length / mtu;
        final numberOfTimesInt = numberOfTimes.toInt();
        int timestoPrint = 0;
        if (numberOfTimes > numberOfTimesInt) {
          timestoPrint = numberOfTimesInt + 1;
        } else {
          timestoPrint = numberOfTimesInt;
        }
        for (var i = 0; i < timestoPrint; i++) {
          final data = bytes.sublist(i * mtu, ((i + 1) * mtu) > bytes.length ? bytes.length : ((i + 1) * mtu));
          await writecharacteristic.write(data);
        }
      } else {
        await writecharacteristic.write(bytes);
      }
      return;
    } catch (e) {
      throw Exception("Fail to print on BLE");
    }
  }

  @override
  Future<bool> isConnected(Printer printer) async {
    try {
      final bt = BluetoothDevice.fromId(printer.address!);
      return bt.isConnected;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> testConnect(Printer printer) async {
    try {
      bool isConnected = false;
      final bt = BluetoothDevice.fromId(printer.address!);
      await bt.connect();
      final stream = bt.connectionState.listen((event) {
        if (event == BluetoothConnectionState.connected) {
          isConnected = true;
        }
      });
      await Future.delayed(const Duration(seconds: 10));
      await stream.cancel();
      await bt.disconnect();
      return isConnected;
    } catch (e) {
      return false;
    }
  }
}
