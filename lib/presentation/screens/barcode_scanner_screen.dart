import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../widgets/barcode_scanner_widget.dart';
import '../../config/app_config.dart';
import '../widgets/flash_toggle_button_widget.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController? _scannerController;

  @override
  void initState() {
    super.initState();
    _initializeController();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _initializeController() async {
    _scannerController = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  void _onBarcodeScanned(String code, String format) {
    setState(() {});
  }

  void _onMenuItemSelected(String value) {
    switch (value) {
      case 'history':
        // TODO: Navigate to history page
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
    if (_scannerController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Flash toggle button
          Container(
            height: 43,
            width: 43,
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: FlashToggleButtonWidget(controller: _scannerController!),
          ),
          Container(
            height: 43,
            width: 43,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: PopupMenuButton<String>(
              icon: Container(
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
          ),
        ],
      ),
      body: BarcodeScannerWidget(
        onBarcodeDetected: _onBarcodeScanned,
        bracketColor: AppConfig.COLOR_DEFAULT,
        controller: _scannerController!, // Pass the controller
      ),
    );
  }
}
