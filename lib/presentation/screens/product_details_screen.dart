import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import '../../domain/models/product.dart';
import '../../config/app_config.dart';
import '../widgets/nutriscore_tooltip_widget.dart';
import '../../controllers/language_controller.dart';

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

  void _openImageGallery(
    BuildContext context,
    List<String> images,
    int initialIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                GalleryScreen(images: images, initialIndex: initialIndex),
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
                _buildProductHeader(),
                if (widget.product.nutriscoreGrade != 'unknown')
                  _buildNutriscore(),
                if (widget.product.allergens.isNotEmpty)
                  _buildAllergensSection(),
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
            // autoPlay: allImages.length > 1, // Auto play if multiple images
            // autoPlayInterval: const Duration(seconds: 4),
            // autoPlayAnimationDuration: const Duration(milliseconds: 800),
            // autoPlayCurve: Curves.fastOutSlowIn,
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
    return GestureDetector(
      onTap: () {
        final List<String> allImages = [
          ...(widget.product.allImages['front'] ?? []).cast<String>(),
          ...(widget.product.allImages['ingredients'] ?? []).cast<String>(),
          ...(widget.product.allImages['nutrition'] ?? []).cast<String>(),
        ];
        _openImageGallery(context, allImages, _currentImageIndex);
      },
      child: Stack(
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
      ),
    );
  }

  Widget _buildProductHeader() {
    final lang = Provider.of<LanguageController>(context);
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name and Brand with better typography
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    letterSpacing: -0.5,
                  ),
                ),
                if (widget.product.brand.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.business, size: 18, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          widget.product.brand,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Origin banner with dynamic color
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      widget.countryName.contains(AppConfig.USER_COUNTRY)
                          ? [Colors.green.shade50, Colors.green.shade100]
                          : [Colors.red.shade50, Colors.red.shade100],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_on,
                      size: 24,
                      color:
                          widget.countryName.contains(AppConfig.USER_COUNTRY)
                              ? Colors.green[700]
                              : Colors.red[700],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.countryName.contains(AppConfig.USER_COUNTRY)
                            ? lang.translate('localProduct')
                            : lang.translate('importedProduct'),
                        style: TextStyle(
                          color:
                              widget.countryName.contains(
                                    AppConfig.USER_COUNTRY,
                                  )
                                  ? Colors.green[700]
                                  : Colors.red[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.countryName,
                        style: TextStyle(
                          color:
                              widget.countryName.contains(
                                    AppConfig.USER_COUNTRY,
                                  )
                                  ? Colors.green[600]
                                  : Colors.red[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutriscore() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nutri-Score',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: _showNutriScoreInfo,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SvgPicture.network(
            '$_nutriscoreBaseUrl${widget.product.nutriscoreGrade}-new-en.svg',
            height: 80,
          ),
        ],
      ),
    );
  }

  Widget _buildAllergensSection() {
    final lang = Provider.of<LanguageController>(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade50, Colors.red.shade100],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red[700]),
                const SizedBox(width: 8),
                Text(
                  lang.translate('allergens'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  widget.product.allergens.map((allergen) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Text(
                        allergen,
                        style: TextStyle(
                          color: Colors.red[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection() {
    final lang = Provider.of<LanguageController>(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.restaurant_menu, size: 24),
                const SizedBox(width: 8),
                Text(
                  lang.translate('ingredients'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  widget.product.ingredients.map((ingredient) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        ingredient,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class GalleryScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const GalleryScreen({
    Key? key,
    required this.images,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late int currentIndex;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            pageController: pageController,
            itemCount: widget.images.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(widget.images[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Image counter
          if (widget.images.length > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${currentIndex + 1}/${widget.images.length}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
