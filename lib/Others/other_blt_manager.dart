import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:flutter_thermal_printer/Others/other_interface.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';

class OtherBltManager implements OtherInterface {
  static final OtherBltManager _instance = OtherBltManager._internal();

  factory OtherBltManager() {
    return _instance;
  }

  StreamSubscription? _bltSubscription;
  final FlutterBlueClassic _flutterBlueClassic = FlutterBlueClassic();
  final Map<String, BluetoothConnection> _connections = Map<String, BluetoothConnection>();

  OtherBltManager._internal();

  @override
  startScan({required Function(List<Printer> printers) callback}) async {
    try {
      if (Platform.isIOS) {
        return;
      }

      if (Platform.isAndroid) {
        if ((await this._flutterBlueClassic.adapterStateNow) != BluetoothAdapterState.on) {
          this._flutterBlueClassic.turnOn();
        }
      }

      await this.stopScan();
      this._bltSubscription = _flutterBlueClassic.scanResults.listen((device) {
        Printer printer = Printer(
          address: device.address,
          name: device.name,
          connectionType: ConnectionType.BLUETOOTH,
        );
        callback([printer]);
      });
      this._flutterBlueClassic.startScan();
    } catch (e) {
      rethrow;
    }
  }

  @override
  stopScan() async {
    if (Platform.isIOS) {
      return;
    }
    this._flutterBlueClassic.stopScan();
    await this._bltSubscription?.cancel();
  }

  @override
  Future print(Printer printer, List<int> bytes, {bool longData = false}) async {
    try {
      BluetoothConnection? connection = this._connections[printer.address];
      if (!(connection?.isConnected ?? false)) {
        this._connections.remove(printer.address);

        if (Platform.isAndroid) {
          if ((await this._flutterBlueClassic.adapterStateNow) != BluetoothAdapterState.on) {
            this._flutterBlueClassic.turnOn();
          }
        }

        connection = await this._flutterBlueClassic.connect(printer.address!);
        if (connection?.isConnected ?? false) {
          this._connections[printer.address!] = connection!;
        }
      }
      if (connection == null) {
        throw Exception("Fail to print on BLUETOOTH CLASSIC");
      }
      connection.output.add(Uint8List.fromList(bytes));
    } catch (e) {
      throw Exception("Fail to print on BLUETOOTH CLASSIC");
    }
  }

  @override
  Future<bool> isConnected(Printer printer) async {
    try {
      if (Platform.isIOS) {
        return false;
      }
      BluetoothConnection? connection = this._connections[printer.address];
      return connection?.isConnected ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> testConnect(Printer printer) async {
    try {
      if (Platform.isIOS) {
        return false;
      }
      if (await this.isConnected(printer)) {
        return true;
      }
      BluetoothConnection? connection = await this._flutterBlueClassic.connect(printer.address!);
      if (connection?.isConnected ?? false) {
        await connection?.finish();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
