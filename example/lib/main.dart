import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flutterThermalPrinterPlugin = FlutterThermalPrinter.instance;

  List<Printer> printers = [];

  StreamSubscription<List<Printer>>? _devicesStreamSubscription;

  // Get Printer List
  void startScan() async {
    _devicesStreamSubscription?.cancel();
    await _flutterThermalPrinterPlugin.startScan();
    _devicesStreamSubscription = _flutterThermalPrinterPlugin.devicesStream.listen((List<Printer> event) {
      log(event.map((e) => e.name).toList().toString());
      setState(() {
        printers = event;
        printers.removeWhere((element) => element.name == null || element.name == '');
      });
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Permission.bluetoothScan.request();
    });
  }

  stopScan() {
    _flutterThermalPrinterPlugin.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Get Printers'),
              onPressed: () {
                startScan();
              },
            ),
            ElevatedButton(
              child: const Text('Stop Scan'),
              onPressed: () {
                stopScan();
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: printers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () async {
                      final profile = await CapabilityProfile.load();
                      final generator = Generator(PaperSize.mm80, profile);
                      List<int> bytes = [];
                      bytes += generator.text(
                        "Sunil Kumar",
                        styles: const PosStyles(
                          bold: true,
                          height: PosTextSize.size3,
                          width: PosTextSize.size3,
                        ),
                      );
                      bytes += generator.text(
                        "Sunil Kumar",
                        styles: const PosStyles(
                          bold: true,
                          height: PosTextSize.size3,
                          width: PosTextSize.size3,
                        ),
                      );
                      bytes += generator.text(
                        "Sunil Kumar",
                        styles: const PosStyles(
                          bold: true,
                          height: PosTextSize.size3,
                          width: PosTextSize.size3,
                        ),
                      );
                      bytes += generator.text(
                        "Sunil Kumar",
                        styles: const PosStyles(
                          bold: true,
                          height: PosTextSize.size3,
                          width: PosTextSize.size3,
                        ),
                      );
                      bytes += generator.text(
                        "Sunil Kumar",
                        styles: const PosStyles(
                          bold: true,
                          height: PosTextSize.size3,
                          width: PosTextSize.size3,
                        ),
                      );
                      bytes += generator.cut();
                      await _flutterThermalPrinterPlugin.print(
                        printers[index],
                        bytes,
                        longData: true,
                      );
                    },
                    title: Text(printers[index].name ?? 'No Name'),
                    subtitle: Text(printers[index].connectionType?.name ?? ""),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget receiptWidget() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      width: 300,
      height: 300,
      child: const Center(
        child: Column(
          children: [
            Text(
              "FLUTTER THERMAL PRINTER",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Hello World",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "This is a test receipt",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
