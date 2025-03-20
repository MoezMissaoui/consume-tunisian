import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import '../widgets/barcode_scanner_widget.dart';
import '../../domain/barcode_validator.dart';
import '../../config/app_config.dart';
import '../widgets/validator_label.dart';
import '../../data/api/product_api.dart';
import '../../domain/models/product.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  static const String _nutriscoreBaseUrl =
      'https://static.openfoodfacts.org/images/attributes/dist/nutriscore-';

  String _barcode = '';
  String _message = AppConfig.DEFAULT_SCAN_MESSAGE;
  bool _isValidBarcode = false;
  bool _isLoading = false;
  Product? _product;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> _onBarcodeScanned(String code) async {
    if (!mounted) return;
    setState(() {
      _barcode = code;
      _isLoading = true;
      _message = AppConfig.CHECKING_MESSAGE;
    });

    try {
      if (BarcodeValidator.isValidBarcode(code) &&
          BarcodeValidator.isTunisianProduct(code)) {
        _product = await ProductApi.getProduct(code);
        _isValidBarcode = true;
        _message =
            _product != null
                ? AppConfig.TUNISIAN_PRODUCT_MESSAGE
                : 'Produit tunisien, mais aucun détail disponible';
      } else {
        _product = null;
        _isValidBarcode = false;
        _message = BarcodeValidator.message(code);
      }
    } catch (e) {
      _message = 'Erreur lors du traitement du produit';
      _isValidBarcode = false;
      _product = null;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resetScan() {
    setState(() {
      _barcode = '';
      _message = AppConfig.DEFAULT_SCAN_MESSAGE;
      _isValidBarcode = false;
      _product = null;
    });
  }

  void _showNutriScoreInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nutri-Score',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      tooltip: AppConfig.CLOSE,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "À quoi sert le Nutri-Score ?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Il offre aux consommateurs une information claire et aisément compréhensible sur la qualité nutritionnelle globale d'un produit, directement sur l'emballage, facilitant ainsi les choix lors des achats. Cette étiquette permet de comparer aisément les aliments et d'opter pour ceux ayant une meilleure valeur nutritionnelle.\n\nCe repère visuel s'inspire des travaux de l'équipe du Pr Serge Hercberg. Le logo utilise une gamme de cinq couleurs, allant du vert foncé au orange foncé, et est associé à des lettres de A (indiquant la \"meilleure qualité nutritionnelle\") à E (représentant la \"qualité nutritionnelle la moins bonne\").",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppConfig.COPIED_MESSAGE),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildProductCard() {
    // Create a flat list of all images
    final allImages = [
      ...(_product!.allImages['front'] ?? []),
      ...(_product!.allImages['ingredients'] ?? []),
      ...(_product!.allImages['nutrition'] ?? []),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (allImages.isNotEmpty) ...[
              CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  viewportFraction: 1.0,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  autoPlay: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                ),
                items:
                    allImages.map((url) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder:
                                (context, error, stackTrace) => Tooltip(
                                  message: AppConfig.ERROR_ICON_TEXT,
                                  child: Icon(Icons.error),
                                ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    allImages.asMap().entries.map((entry) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor.withOpacity(
                            _currentImageIndex == entry.key ? 0.9 : 0.4,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const Divider(height: 24),
            ],
            if (_product!.nutriscoreGrade != 'unknown') ...[
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.network(
                      '$_nutriscoreBaseUrl${_product!.nutriscoreGrade}-new-en.svg',
                      height: 80,
                      placeholderBuilder:
                          (context) => const SizedBox(
                            height: 80,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: _showNutriScoreInfo,
                      tooltip: AppConfig.NUTRISCORE_ABOUT,
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${AppConfig.LABEL_CODE}: ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: _product!.code,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () => _copyToClipboard(_product!.code),
                  tooltip: AppConfig.COPY_TOOLTIP,
                ),
              ],
            ),
            const Divider(height: 16),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${AppConfig.LABEL_NAME}: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: _product!.name,
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${AppConfig.LABEL_BRAND}: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: _product!.brand,
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${AppConfig.LABEL_ORIGIN}: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: _product!.origin,
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),
            if (_product!.allergens.isNotEmpty) ...[
              const Text(
                'Allergies:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _product!.allergens
                        .map(
                          (allergen) => Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 3.0,
                              horizontal: 5.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Text(
                              allergen,
                              style: TextStyle(
                                color: Colors.red[900],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              const Divider(height: 16),
            ],
            const Text(
              'Ingredients:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _product!.ingredients
                      .map(
                        (i) => Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 3.0,
                            horizontal: 5.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Text(
                            i,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.white, size: 50),
                SizedBox(height: 10),
                Text(
                  'Consommer Tunisien',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            onTap: () {
              Navigator.pop(context);
              _resetScan();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('À propos'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('À propos'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consommer Tunisien',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Cette application vous permet de vérifier si un produit est fabriqué en Tunisie en scannant son code-barres.',
                ),
                SizedBox(height: 16),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final scannerHeight = screenHeight * 0.2; // Reduce from 0.4 to 0.35

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
        elevation: 0,
        shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          AppConfig.APP_TITLE,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_barcode.isNotEmpty)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: _resetScan,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: Text(AppConfig.NEW_SCAN),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),

              if (_barcode.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Add this
                    children: [
                      Text(
                        AppConfig.SCAN_INSTRUCTION,
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: scannerHeight,
                        child: BarcodeScannerWidget(
                          onBarcodeDetected: _onBarcodeScanned,
                          bracketColor:
                              _barcode.isEmpty
                                  ? AppConfig.COLOR_DEFAULT
                                  : _isValidBarcode
                                  ? AppConfig.COLOR_SUCCESS
                                  : AppConfig.COLOR_FAILER,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              if (_isLoading)
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 8),
                      Text(AppConfig.LOADING_TEXT),
                    ],
                  ),
                ),
              if (_barcode.isNotEmpty && !_isLoading) ...[
                Center(
                  child: ValidatorLabel(
                    isValidBarcode: _isValidBarcode,
                    message: _message,
                  ),
                ),
                if (_product != null) ...[
                  const SizedBox(height: 16),
                  _buildProductCard(),
                  const SizedBox(height: 16),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
