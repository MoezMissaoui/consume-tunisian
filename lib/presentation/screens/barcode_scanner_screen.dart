import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/barcode_scanner_widget.dart';
import '../../config/app_config.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _onBarcodeScanned(String code, String format) {
    setState(() {});
  }

  void _onMenuItemSelected(String value) {
    switch (value) {
      case 'history':
        // TODO: Navigate to history page
        break;
      case 'favorites':
        // TODO: Navigate to favorites page
        break;
      case 'settings':
        // TODO: Navigate to settings page
        break;
      case 'about':
        // TODO: Navigate to about page
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.more_horiz, color: Colors.white),
            ),
            onSelected: _onMenuItemSelected,
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'history',
                    child: Row(
                      children: [
                        Icon(Icons.history, size: 20),
                        SizedBox(width: 8),
                        Text('Historique'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'favorites',
                    child: Row(
                      children: [
                        Icon(Icons.favorite, size: 20),
                        SizedBox(width: 8),
                        Text('Favoris'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, size: 20),
                        SizedBox(width: 8),
                        Text('Paramètres'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'about',
                    child: Row(
                      children: [
                        Icon(Icons.info, size: 20),
                        SizedBox(width: 8),
                        Text('À propos'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: BarcodeScannerWidget(
        onBarcodeDetected: _onBarcodeScanned,
        bracketColor: AppConfig.COLOR_DEFAULT,
      ),
    );
  }
}
