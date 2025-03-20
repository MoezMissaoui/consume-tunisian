import 'package:consume_tunisian/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'flash_toggle_button.dart';
import 'corner_bracket_painter.dart';

typedef BarcodeCallback = void Function(String barcode);

class BarcodeScannerWidget extends StatefulWidget {
  final BarcodeCallback onBarcodeDetected;
  final Color bracketColor;

  const BarcodeScannerWidget({
    Key? key,
    required this.onBarcodeDetected,
    required this.bracketColor,
  }) : super(key: key);

  @override
  _BarcodeScannerWidgetState createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  final MobileScannerController _controller = MobileScannerController();
  late Color _currentBracketColor;

  @override
  void initState() {
    super.initState();
    _currentBracketColor = widget.bracketColor;
  }

  @override
  void didUpdateWidget(BarcodeScannerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bracketColor != widget.bracketColor) {
      setState(() {
        _currentBracketColor = widget.bracketColor;
      });
    }
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        widget.onBarcodeDetected(barcode.rawValue!);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(controller: _controller, onDetect: _onBarcodeDetected),
        Positioned(
          top: -5,
          right: -10,
          child: FlashToggleButton(controller: _controller),
        ),
        Center(
          child: Container(
            width: 230,
            height: 90,
            child: CustomPaint(
              painter: CornerBracketPainter(color: _currentBracketColor),
            ),
          ),
        ),
      ],
    );
  }
}
