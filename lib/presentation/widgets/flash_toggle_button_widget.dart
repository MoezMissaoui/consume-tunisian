import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class FlashToggleButtonWidget extends StatefulWidget {
  final MobileScannerController controller;

  const FlashToggleButtonWidget({super.key, required this.controller});

  @override
  _FlashToggleButtonWidgetState createState() =>
      _FlashToggleButtonWidgetState();
}

class _FlashToggleButtonWidgetState extends State<FlashToggleButtonWidget> {
  bool _isFlashOn = false;

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
      widget.controller.toggleTorch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isFlashOn ? Icons.flash_on : Icons.flash_off,
        color: Colors.white,
      ),
      onPressed: _toggleFlash,
    );
  }
}
