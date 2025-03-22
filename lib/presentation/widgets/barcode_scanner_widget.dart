import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../config/barcode_countries.dart';
import 'flash_toggle_button_widget.dart';
import 'corner_bracket_painter_widget.dart';
import '../../config/app_config.dart';
import '../../controllers/language_controller.dart';

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
  final DragStartBehavior dragStartBehavior = DragStartBehavior.down;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // Increased duration
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic, // Smoother curve
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
    final lang = Provider.of<LanguageController>(context);
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
              // Enhanced title and instructions above scanner window
              Positioned(
                top: size.height * 0.12,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    // App Title
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.withOpacity(0.8),
                            Colors.blue.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        lang.translate('appTitle'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Scanning Instructions
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_scanner,
                                color: Colors.white.withOpacity(0.8),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                lang.translate('instructions'),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            lang.translate('scanInstructions'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Scanner window overlay
              Positioned(
                top: size.height * 0.4,
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
        // Result Card with improved animation
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  0,
                  (1 - _fadeAnimation.value) * 300,
                ), // Increased translation distance
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _fadeController,
                      curve: const Interval(0.4, 1.0), // Delayed fade in
                    ),
                  ),
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      if (details.primaryDelta! > 0) {
                        _fadeController.value -= details.primaryDelta! / 200;
                      }
                    },
                    onVerticalDragEnd: (details) {
                      if (_fadeController.value < 0.5) {
                        _hideCard();
                      } else {
                        _fadeController.forward();
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Handle bar indicator
                          Center(
                            child: Container(
                              margin: const EdgeInsets.only(top: 8),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                if (_lastCode != null) ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _lastCode!,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy),
                                        onPressed:
                                            () => _copyToClipboard(_lastCode!),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                if (_lastFormat != null || _lastCountry != null)
                                  Row(
                                    children: [
                                      if (_lastFormat != null)
                                        _buildModernChip(
                                          _lastFormat!,
                                          Icons.qr_code_2,
                                          Colors.blue,
                                        ),
                                      const SizedBox(width: 8),
                                      if (_lastCountry != null)
                                        _buildModernChip(
                                          _lastCountry!,
                                          Icons.location_on,
                                          _lastCountry!.contains(
                                                AppConfig.USER_COUNTRY,
                                              )
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          // Search button
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search, color: Colors.purple[700]),
                                const SizedBox(width: 8),
                                Text(
                                  lang.translate('seeDetails'),
                                  style: TextStyle(
                                    color: Colors.purple[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildModernChip(String label, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color[700]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color[700], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
