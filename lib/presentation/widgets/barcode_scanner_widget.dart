import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import '../../config/barcode_countries.dart';
import 'flash_toggle_button_widget.dart';
import 'corner_bracket_painter_widget.dart';
import '../../config/app_config.dart';

typedef BarcodeCallback = void Function(String code, String format);

class BarcodeScannerWidget extends StatefulWidget {
  final BarcodeCallback onBarcodeDetected;
  final Color bracketColor;
  final MobileScannerController controller;

  const BarcodeScannerWidget({
    super.key,
    required this.onBarcodeDetected,
    required this.bracketColor,
    required this.controller,
  });

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String? _lastCode;
  String? _lastFormat;
  String? _lastCountry;
  bool _isCardVisible = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
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
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text('Code copié dans le presse-papiers'),
    //     duration: Duration(seconds: 1),
    //   ),
    // );
  }

  void _onBarcodeDetected(String code, String format, String? country) {
    setState(() {
      _lastCode = code;
      _lastFormat = format;
      _lastCountry = country;
      if (!_isCardVisible) {
        _isCardVisible = true;
        _fadeController.forward();
      }
    });
  }

  void _hideCard() {
    _fadeController.reverse().then((_) {
      setState(() {
        _isCardVisible = false;
        _lastCode = null;
        _lastFormat = null;
        _lastCountry = null;
      });
    });
  }

  Widget _buildCodeRow(String code) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () => _copyToClipboard(code),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanArea = size.width * 0.8; // 80% of screen width

    return Stack(
      children: [
        // Full screen scanner
        MobileScanner(
          controller: widget.controller, // Use passed controller
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (_isBarcodeFormat(barcode.format)) {
                final code = barcode.rawValue ?? '';
                final format = barcode.format.name;
                final country = getCountryFromBarcode(code);
                _onBarcodeDetected(code, format, country);
                widget.onBarcodeDetected(code, format);
              }
            }
          },
        ),
        // Replace ColorFiltered with simple overlay
        Container(
          color: Colors.black.withOpacity(0.5),
          child: Stack(
            children: [
              // Add title above scanner window
              Positioned(
                top: size.height * 0.17, // Position above scanner window
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      AppConfig.APP_TITLE,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Scanner window overlay
              Positioned(
                top: size.height * 0.3,
                left: (size.width - scanArea) / 2,
                child: Container(
                  height: scanArea * 0.5,
                  width: scanArea,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    color: Colors.transparent,
                  ),
                  child: CustomPaint(
                    painter: CornerBracketPainterWidget(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Result Card - Modified positioning
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(_fadeAnimation),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.25,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            20,
                            80,
                            16,
                          ), // Added right padding for search button
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_lastCode != null) _buildCodeRow(_lastCode!),
                              if (_lastFormat != null || _lastCountry != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      if (_lastFormat != null)
                                        _buildChip(_lastFormat!, Colors.blue),
                                      if (_lastCountry != null) ...[
                                        const SizedBox(width: 8),
                                        _buildChip(
                                          _lastCountry!,
                                          _lastCountry!.contains(
                                                AppConfig.USER_COUNTRY,
                                              )
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Search button positioned on right center
                        Positioned(
                          right: 40,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.search, size: 24),
                                color: Colors.purple,
                                onPressed: () {
                                  if (_lastCode != null) {
                                    widget.onBarcodeDetected(
                                      _lastCode!,
                                      _lastFormat ?? '',
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        // Close button
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                              onPressed: _hideCard,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: color[700], fontSize: 12)),
    );
  }
}
