import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import '../../config/barcode_countries.dart';
import 'flash_toggle_button_widget.dart';
import 'corner_bracket_painter_widget.dart';

typedef BarcodeCallback = void Function(String code, String format);

class BarcodeScannerWidget extends StatefulWidget {
  final BarcodeCallback onBarcodeDetected;
  final Color bracketColor;

  const BarcodeScannerWidget({
    super.key,
    required this.onBarcodeDetected,
    required this.bracketColor,
  });

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  final MobileScannerController controller = MobileScannerController();
  String? _lastCode;
  String? _lastFormat;
  String? _lastCountry;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool _isBarcodeFormat(BarcodeFormat format) {
    return format == BarcodeFormat.ean8 ||
        format == BarcodeFormat.ean13 ||
        format == BarcodeFormat.upcA ||
        format == BarcodeFormat.code128 ||
        format == BarcodeFormat.codebar ||
        format == BarcodeFormat.code39 ||
        format == BarcodeFormat.code93 ||
        format == BarcodeFormat.dataMatrix ||
        format == BarcodeFormat.itf ||
        format == BarcodeFormat.pdf417 ||
        format == BarcodeFormat.aztec ||
        format == BarcodeFormat.upcE;
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copié dans le presse-papiers'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (_isBarcodeFormat(barcode.format)) {
                final code = barcode.rawValue ?? '';
                final format = barcode.format.name;
                setState(() {
                  _lastCode = code;
                  _lastFormat = format;
                  _lastCountry = getCountryFromBarcode(code);
                });
                widget.onBarcodeDetected(code, format);
              }
            }
          },
        ),
        Container(
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 270,
                  height: 270,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: CustomPaint(
                    painter: CornerBracketPainterWidget(
                      color: widget.bracketColor,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: FlashToggleButtonWidget(controller: controller),
                ),
              ),
              if (_lastCode != null)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _lastCode!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () => _copyToClipboard(_lastCode!),
                              iconSize: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (_lastFormat != null)
                              Chip(
                                label: Text(_lastFormat!),
                                backgroundColor: Colors.blue.withOpacity(0.1),
                                labelStyle: TextStyle(color: Colors.blue[700]),
                              ),
                            if (_lastCountry != null) ...[
                              const SizedBox(width: 8),
                              Chip(
                                label: Text(_lastCountry!),
                                backgroundColor: Colors.green.withOpacity(0.1),
                                labelStyle: TextStyle(color: Colors.green[700]),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
