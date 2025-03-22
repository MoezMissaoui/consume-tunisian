import 'package:consume_tunisian/config/barcode_countries.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../widgets/barcode_scanner_widget.dart';
import '../../config/app_config.dart';
import '../widgets/flash_toggle_button_widget.dart';
import '../screens/about_screen.dart';
import '../screens/settings_screen.dart';
import '../../controllers/language_controller.dart';
import '../../services/history_manager.dart';
import 'history_screen.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController? _scannerController;
  final HistoryManager _historyManager = HistoryManager();

  @override
  void initState() {
    super.initState();
    // Initialize controller immediately
    _scannerController = MobileScannerController(
      facing: CameraFacing.back,
      formats: [
        BarcodeFormat.ean8,
        BarcodeFormat.ean13,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
      ],
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  void _onBarcodeScanned(String code, String format) async {
    final country = getCountryFromBarcode(code) ?? 'Unknown';
    if (!await _historyManager.isCodeAlreadySaved(code)) {
      await _historyManager.addScan(code, format, country);
    }
    setState(() {});
  }

  void _onMenuItemSelected(String value) {
    switch (value) {
      case 'about':
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => const AboutScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
            reverseTransitionDuration: const Duration(milliseconds: 300),
          ),
        );
        break;
      case 'history':
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const HistoryScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
            reverseTransitionDuration: const Duration(milliseconds: 300),
          ),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const SettingsScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
            reverseTransitionDuration: const Duration(milliseconds: 300),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageController>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth:
            200, // Increase leading width to accommodate multiple buttons
        leading: Row(
          children: [
            Container(
              height: 43,
              width: 43,
              // margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: FlashToggleButtonWidget(controller: _scannerController!),
            ),
            const SizedBox(width: 8),
            Container(
              height: 43,
              width: 43,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                onPressed: () => _scannerController?.switchCamera(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 43,
              width: 43,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.aspect_ratio, color: Colors.white),
                onPressed: () {
                  // TODO: Handle aspect ratio toggle
                },
              ),
            ),
          ],
        ),
        actions: [
          Container(
            height: 43,
            width: 43,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: PopupMenuButton<String>(
              offset: const Offset(
                0,
                10,
              ), // Add offset to position menu below icon
              color: Colors.black.withOpacity(0.9),
              position: PopupMenuPosition.under, // Force menu to appear under
              icon: const Icon(Icons.more_horiz, color: Colors.white),
              onSelected: _onMenuItemSelected,
              itemBuilder:
                  (BuildContext context) => [
                    PopupMenuItem(
                      value: 'history',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.history,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            lang.translate('history'),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.settings,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            lang.translate('settings'),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'about',
                      child: Row(
                        children: [
                          const Icon(Icons.info, size: 20, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            lang.translate('about'),
                            style: const TextStyle(color: Colors.white),
                          ),
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
