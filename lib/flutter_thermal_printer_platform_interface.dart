import 'dart:typed_data';

import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_thermal_printer_method_channel.dart';

abstract class FlutterThermalPrinterPlatform extends PlatformInterface {
  FlutterThermalPrinterPlatform() : super(token: _token);
  static final Object _token = Object();
  static FlutterThermalPrinterPlatform _instance = MethodChannelFlutterThermalPrinter();

  static FlutterThermalPrinterPlatform get instance => _instance;

  static set instance(FlutterThermalPrinterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<dynamic> startUsbScan() {
    throw UnimplementedError('startScan() has not been implemented.');
  }

  Future<bool> connect({required String vendorId, required String productId}) {
    throw UnimplementedError("connect() has not been implemented.");
  }

  Future<bool> printText({required String vendorId, required String productId, required Uint8List data, String? path}) {
    throw UnimplementedError("printText() has not been implemented.");
  }

  Future<bool> isConnected({required String vendorId, required String productId}) {
    throw UnimplementedError("isConnected() has not been implemented.");
  }

  Future<dynamic> convertImageToGrayscale(Uint8List? value) {
    throw UnimplementedError("convertImageToGrayscale() has not been implemented.");
  }

  Future<bool> disconnect({required String vendorId, required String productId}) {
    throw UnimplementedError("disconnect() has not been implemented.");
  }

  Future<void> stopScan() {
    throw UnimplementedError("stopScan() has not been implemented.");
  }

  Future<void> getPrinters() {
    throw UnimplementedError("getPrinters() has not been implemented.");
  }
}
