import 'package:consume_tunisian/config/app_config.dart';
import 'package:flutter/material.dart';
import 'presentation/screens/barcode_scanner_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.APP_TITLE,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: BarcodeScannerScreen(),
    );
  }
}
