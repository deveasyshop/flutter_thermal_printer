import 'package:flutter_thermal_printer/utils/printer.dart';

abstract class OtherInterface {
  startScan({required Function(List<Printer>) callback});

  stopScan();

  Future<bool> testConnect(Printer printer);

  Future<bool> isConnected(Printer printer);

  Future print(Printer printer, List<int> bytes, {bool longData = false});


}
