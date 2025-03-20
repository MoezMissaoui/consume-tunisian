import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class FlashToggleButton extends StatefulWidget {
  final MobileScannerController controller;

  const FlashToggleButton({Key? key, required this.controller})
    : super(key: key);

  @override
  _FlashToggleButtonState createState() => _FlashToggleButtonState();
}

class _FlashToggleButtonState extends State<FlashToggleButton> {
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
