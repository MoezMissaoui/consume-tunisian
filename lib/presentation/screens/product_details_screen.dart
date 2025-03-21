import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../domain/models/product.dart';
import '../../config/app_config.dart';
import '../widgets/nutriscore_tooltip_widget.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final String countryName;
  final String barcodeType;

  const ProductDetailsScreen({
    Key? key,
    required this.product,
    required this.countryName,
    required this.barcodeType,
  }) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  static const String _nutriscoreBaseUrl =
      'https://static.openfoodfacts.org/images/attributes/dist/nutriscore-';

  void _showNutriScoreInfo() {
    NutriscoreTooltipWidget.show(context);
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

  @override
  Widget build(BuildContext context) {
    final allImages = [
      ...(widget.product.allImages['front'] ?? []),
      ...(widget.product.allImages['ingredients'] ?? []),
      ...(widget.product.allImages['nutrition'] ?? []),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.product.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Code Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Code: ${widget.product.code}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Format: ${widget.barcodeType}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed:
                                () => _copyToClipboard(widget.product.code),
                            tooltip: AppConfig.COPY_TOOLTIP,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Product Details Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (allImages.isNotEmpty) ...[
                        Stack(
                          children: [
                            CarouselSlider(
                              options: CarouselOptions(
                                height: 250,
                                viewportFraction: 1.0,
                                enlargeCenterPage: false,
                                onPageChanged: (index, reason) {
                                  setState(() => _currentImageIndex = index);
                                },
                              ),
                              items:
                                  allImages
                                      .map(
                                        (url) => Image.network(
                                          url,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (_, __, ___) =>
                                                  const Icon(Icons.error),
                                        ),
                                      )
                                      .toList(),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                    allImages.asMap().entries.map((entry) {
                                      return Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(
                                            _currentImageIndex == entry.key
                                                ? 0.9
                                                : 0.4,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ],

                      if (widget.countryName.isNotEmpty) ...[
                        Text(
                          'Produit de: ${widget.countryName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (widget.product.nutriscoreGrade != 'unknown') ...[
                        Center(
                          child: Column(
                            children: [
                              SvgPicture.network(
                                '$_nutriscoreBaseUrl${widget.product.nutriscoreGrade}-new-en.svg',
                                height: 80,
                              ),
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: _showNutriScoreInfo,
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                      ],

                      if (widget.product.name.isNotEmpty) ...[
                        _buildInfoRow(
                          AppConfig.LABEL_NAME,
                          widget.product.name,
                          false,
                        ),
                        const Divider(),
                      ],

                      if (widget.product.brand.isNotEmpty) ...[
                        _buildInfoRow(
                          AppConfig.LABEL_BRAND,
                          widget.product.brand,
                          false,
                        ),
                        const Divider(),
                      ],

                      if (widget.product.origin.isNotEmpty) ...[
                        _buildInfoRow(
                          AppConfig.LABEL_ORIGIN,
                          widget.product.origin,
                          false,
                        ),
                        const Divider(),
                      ],

                      if (widget.product.allergens.isNotEmpty) ...[
                        const Text(
                          'Allergènes:',
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
                              widget.product.allergens
                                  .map(
                                    (allergen) => Chip(
                                      backgroundColor: Colors.red[50],
                                      label: Text(allergen),
                                      labelStyle: TextStyle(
                                        color: Colors.red[900],
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                        const Divider(),
                      ],

                      if (widget.product.ingredients.isNotEmpty) ...[
                        const Text(
                          'Ingrédients:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              widget.product.ingredients
                                  .map(
                                    (ingredient) => Chip(
                                      backgroundColor: Colors.grey[200],
                                      label: Text(ingredient),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool showCopy) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          if (showCopy)
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () => _copyToClipboard(value),
              tooltip: AppConfig.COPY_TOOLTIP,
            ),
        ],
      ),
    );
  }
}
