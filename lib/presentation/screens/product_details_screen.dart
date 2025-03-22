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
  final ScrollController _scrollController = ScrollController();
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
    final List<String> allImages = [
      ...(widget.product.allImages['front'] ?? []).cast<String>(),
      ...(widget.product.allImages['ingredients'] ?? []).cast<String>(),
      ...(widget.product.allImages['nutrition'] ?? []).cast<String>(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.white,
            // Add this to create space for status bar
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  if (allImages.isNotEmpty) _buildImageCarousel(allImages),
                  // Add safe area for top padding
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    right: 16,
                    child:
                        allImages.length > 1
                            ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.photo_library,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_currentImageIndex + 1}/${allImages.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : const SizedBox(),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Product Header
                _buildProductHeader(),

                // Nutriscore Section
                if (widget.product.nutriscoreGrade != 'unknown')
                  _buildNutriscore(),

                // Product Details
                _buildDetailsSection(),

                // Allergens Section
                if (widget.product.allergens.isNotEmpty)
                  _buildAllergensSection(),

                // Ingredients Section
                if (widget.product.ingredients.isNotEmpty)
                  _buildIngredientsSection(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(List<String> allImages) {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 300,
            viewportFraction: 1.0,
            onPageChanged:
                (index, _) => setState(() => _currentImageIndex = index),
            autoPlay: allImages.length > 1, // Auto play if multiple images
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
          ),
          items: allImages.map((url) => _buildImageItem(url)).toList(),
        ),
        // Image dots indicator
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                allImages.asMap().entries.map((entry) {
                  final isSelected = _currentImageIndex == entry.key;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: isSelected ? 24 : 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(isSelected ? 0.95 : 0.5),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 0.5,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildImageItem(String url) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.error),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.2, 0.8, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (widget.product.brand.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.product.brand,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 16),
          _buildOriginChip(),
        ],
      ),
    );
  }

  Widget _buildOriginChip() {
    final isLocal = widget.countryName.contains(AppConfig.USER_COUNTRY);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (isLocal ? Colors.green : Colors.red).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isLocal ? Colors.green : Colors.red).withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            size: 18,
            color: isLocal ? Colors.green[700] : Colors.red[700],
          ),
          const SizedBox(width: 8),
          Text(
            widget.countryName,
            style: TextStyle(
              color: isLocal ? Colors.green[700] : Colors.red[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutriscore() {
    return Center(
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
    );
  }

  Widget _buildDetailsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(AppConfig.LABEL_NAME, widget.product.name, false),
            const Divider(),
            _buildInfoRow(AppConfig.LABEL_BRAND, widget.product.brand, false),
            const Divider(),
            _buildInfoRow(AppConfig.LABEL_ORIGIN, widget.product.origin, false),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergensSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Allergènes:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
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
                          labelStyle: TextStyle(color: Colors.red[900]),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
