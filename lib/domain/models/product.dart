class Product {
  final String code;
  final String name;
  final String brand;
  final String quantity;
  final String origin;
  final List<String> ingredients;
  final Map<String, dynamic> nutriments;
  final String nutriscoreGrade;
  final Map<String, String> images;
  final List<String> allergens;
  final Map<String, List<String>> allImages;

  Product({
    required this.code,
    required this.name,
    required this.brand,
    required this.quantity,
    required this.origin,
    required this.ingredients,
    required this.nutriments,
    required this.nutriscoreGrade,
    required this.images,
    required this.allImages,
    required this.allergens,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final product = json['product'];

    // Safely extract display URLs from selected_images
    Map<String, String> displayImages = {};
    try {
      final selectedImages = product['selected_images'];
      if (selectedImages != null && selectedImages['front'] != null) {
        final display = selectedImages['front']['display'];
        if (display != null) {
          displayImages = Map<String, String>.from(display);
        }
      }
    } catch (e) {
      displayImages = {};
    }

    // Safely extract all image types
    Map<String, List<String>> allImages = {};
    try {
      final selectedImages = product['selected_images'];
      if (selectedImages != null) {
        // Extract front images
        if (selectedImages['front']?['display'] != null) {
          final frontDisplay = Map<String, dynamic>.from(
            selectedImages['front']['display'],
          );
          allImages['front'] =
              frontDisplay.values.map((v) => v.toString()).toList();
        }
        // Extract ingredients images
        if (selectedImages['ingredients']?['display'] != null) {
          final ingredientsDisplay = Map<String, dynamic>.from(
            selectedImages['ingredients']['display'],
          );
          allImages['ingredients'] =
              ingredientsDisplay.values.map((v) => v.toString()).toList();
        }
        // Extract nutrition images
        if (selectedImages['nutrition']?['display'] != null) {
          final nutritionDisplay = Map<String, dynamic>.from(
            selectedImages['nutrition']['display'],
          );
          allImages['nutrition'] =
              nutritionDisplay.values.map((v) => v.toString()).toList();
        }
      }
    } catch (e) {
      print('Error parsing images: $e');
      allImages = {'front': [], 'ingredients': [], 'nutrition': []};
    }

    // Safely extract and clean ingredients
    List<String> ingredients = [];
    try {
      final ingredientsTags = product['ingredients_tags'];
      if (ingredientsTags != null) {
        ingredients =
            List<String>.from(
              ingredientsTags,
            ).map((ingredient) => _cleanIngredientText(ingredient)).toList();
      }
    } catch (e) {
      ingredients = [];
    }

    // Safely extract and clean allergens
    List<String> allergens = [];
    try {
      final allergensTags = product['allergens_tags'];
      if (allergensTags != null) {
        allergens =
            List<String>.from(
              allergensTags,
            ).map((allergen) => _cleanIngredientText(allergen)).toList();
      }
    } catch (e) {
      allergens = [];
    }

    return Product(
      code: product['code'] ?? '',
      name: product['product_name'] ?? '',
      brand: product['brands'] ?? '',
      quantity: product['product_quantity'] ?? '',
      origin: product['origin'] ?? '',
      ingredients: ingredients,
      nutriments: product['nutriments'] ?? {},
      nutriscoreGrade: product['nutriscore_grade'] ?? 'unknown',
      images: displayImages,
      allImages: allImages,
      allergens: allergens,
    );
  }

  static String _cleanIngredientText(String item) {
    // Remove everything before the colon and clean up the text
    return item
        .replaceAll(
          RegExp(r'^.*?:'),
          '',
        ) // Remove everything before and including :
        .replaceAll('-', ' ') // Replace dashes with spaces
        .trim() // Remove leading/trailing whitespace
        .toLowerCase() // Convert to lowercase
        .split(' ') // Split into words
        .map(
          (word) =>
              word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1)}' // Capitalize first letter
                  : '',
        )
        .join(' ') // Join words back together
        .trim(); // Final trim
  }
}
