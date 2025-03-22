import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../widgets/barcode_scanner_widget.dart';
import '../../config/app_config.dart';
import '../widgets/flash_toggle_button_widget.dart';
import '../screens/about_screen.dart';
import '../screens/settings_screen.dart';

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

  void _onBarcodeScanned(String code, String format) {
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
        // TODO: Navigate to history page
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
              color: Colors.black.withOpacity(0.5),
              position: PopupMenuPosition.under, // Force menu to appear under
              icon: const Icon(Icons.more_horiz, color: Colors.white),
              onSelected: _onMenuItemSelected,
              itemBuilder:
                  (BuildContext context) => [
                    // const PopupMenuItem(
                    //   value: 'history',
                    //   child: Row(
                    //     children: [
                    //       Icon(Icons.history, size: 20, color: Colors.white),
                    //       SizedBox(width: 8),
                    //       Text(
                    //         'Historique',
                    //         style: TextStyle(color: Colors.white),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings, size: 20, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Paramètres',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'about',
                      child: Row(
                        children: [
                          Icon(Icons.info, size: 20, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'À propos',
                            style: TextStyle(color: Colors.white),
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
