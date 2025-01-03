import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_thermal_printer/Others/other_interface.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer_platform_interface.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';

class OtherUsbManager implements OtherInterface {
  static final OtherUsbManager _instance = OtherUsbManager._internal();

  factory OtherUsbManager() {
    return _instance;
  }

  StreamSubscription? _usbSubscription;

  final EventChannel _eventChannel = const EventChannel('flutter_thermal_printer/events');

  OtherUsbManager._internal();

  @override
  startScan({required Function(List<Printer> printers) callback}) async {
    try {
      final devices = await FlutterThermalPrinterPlatform.instance.startUsbScan();
      final usbPrinters = await Future.wait((devices as List).map((device) async {
        final map = Map<String, dynamic>.from(device is String ? jsonDecode(device) : device);
        final printer = Printer(
          vendorId: map['vendorId'].toString(),
          productId: map['productId'].toString(),
          name: map['name'],
          connectionType: ConnectionType.USB,
          address: map['vendorId'].toString(),
        );
        return printer;
      }).toList());
      callback(usbPrinters.cast<Printer>());
      // Look at new connection
      this._usbSubscription?.cancel();
      this._usbSubscription = this._eventChannel.receiveBroadcastStream().listen((event) {
        final map = Map<String, dynamic>.from(event);
        callback([
          Printer(
            vendorId: map['vendorId'].toString(),
            productId: map['productId'].toString(),
            name: map['name'],
            connectionType: ConnectionType.USB,
            address: map['vendorId'].toString(),
          )
        ]);
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  stopScan() async {
    await _usbSubscription?.cancel();
  }

  @override
  Future print(Printer printer, List<int> bytes, {bool longData = false}) async {
    try {
      if (printer.productId == null || printer.vendorId == null) {
        throw Exception("No product ID or no VendorId");
      }
      bool value = await FlutterThermalPrinterPlatform.instance.printText(
        productId: printer.productId!,
        vendorId: printer.vendorId!,
        data: Uint8List.fromList(bytes),
        path: printer.address,
      );
      if (!value) {
        throw Exception("Fail to print on USB");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isConnected(Printer printer) async {
    return await FlutterThermalPrinterPlatform.instance.isConnected(productId: printer.productId!, vendorId: printer.vendorId!);
  }

  @override
  Future<bool> testConnect(Printer printer) async {
    return this.isConnected(printer);
  }
}
