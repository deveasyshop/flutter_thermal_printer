import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_thermal_printer/Others/other_interface.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer_platform_interface.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';

class OtherTcpManager implements OtherInterface {
  static final OtherTcpManager _instance = OtherTcpManager._internal();

  factory OtherTcpManager() {
    return _instance;
  }

  final _defaultPort = 9100;
  StreamSubscription? _tcpSubscription;

  OtherTcpManager._internal();

  @override
  startScan({required Function(List<Printer> printers) callback}) async {
    try {
      this._tcpSubscription?.cancel();
      String? deviceIp;
      if (Platform.isAndroid || Platform.isIOS) {
        deviceIp = await NetworkInfo().getWifiIP();
      }
      if (deviceIp == null) {
        throw Exception("No device IP");
      }

      final String subnet = deviceIp.substring(0, deviceIp.lastIndexOf('.'));
      final stream = NetworkAnalyzer.discover2(subnet, _defaultPort);
      this._tcpSubscription = stream.listen((data) {
        if (data.exists) {
          callback([
            Printer(
              name: data.ip,
              connectionType: ConnectionType.TCP,
              address: data.ip,
            )
          ]);
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  stopScan() async {
    await this._tcpSubscription?.cancel();
  }

  @override
  Future print(Printer printer, List<int> bytes, {bool longData = false}) async {
    try {
      if (printer.address == null) {
        throw Exception("No adresse");
      }
      Socket? _socket = await Socket.connect(printer.address, 9100, timeout: const Duration(seconds: 5));
      _socket.add(Uint8List.fromList(bytes));
      await _socket.flush();
      _socket.destroy();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isConnected(Printer printer) async {
    try {
      Socket socket = await Socket.connect(printer.address, 9100, timeout: const Duration(seconds: 5));
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> testConnect(Printer printer) async {
    return this.isConnected(printer);
  }
}
