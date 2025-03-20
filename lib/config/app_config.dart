import 'package:flutter/material.dart';

class AppConfig {
  // App Information
  static const String APP_TITLE = "Consommer Tunisien";

  // Barcode Configuration
  static const String TUNISIAN_BARCODE_PREFIX = "619";

  // Messages
  static const String DEFAULT_SCAN_MESSAGE = "Scannez un code-barres";
  static const String INVALID_BARCODE_MESSAGE =
      "Format de code-barres invalide";
  static const String TUNISIAN_PRODUCT_MESSAGE = "Produit tunisien trouvé !";
  static const String NON_TUNISIAN_PRODUCT_MESSAGE = "Pas un produit tunisien";
  static const String CHECKING_MESSAGE = "Vérification du produit...";
  static const String NO_DETAILS_MESSAGE =
      "Produit tunisien, mais aucun détail disponible";
  static const String ERROR_MESSAGE = "Erreur lors du traitement";
  static const String COPIED_MESSAGE = "Copié dans le presse-papiers";
  static const String SCAN_INSTRUCTION =
      "Scannez un code-barres pour vérifier si le produit est fabriqué en Tunisie et voir ces details.";
  static const String NEW_SCAN = "Nouveau scan";

  // Product card labels
  static const String LABEL_CODE = "Code";
  static const String LABEL_NAME = "Nom";
  static const String LABEL_BRAND = "Marque";
  static const String LABEL_ORIGIN = "Origine";
  static const String LABEL_ALLERGIES = "Allergènes";
  static const String LABEL_INGREDIENTS = "Ingrédients";

  // Colors
  static const Color COLOR_DEFAULT = Color(0xFF9E9E9E);
  static const Color COLOR_SUCCESS = Color(0xFF4CAF50);
  static const Color COLOR_FAILER = Color(0xFFF44336);

  // Timers
  static const Duration SCAN_RESET_TIMEOUT = Duration(seconds: 3);

  // Additional translations
  static const String COPY_TOOLTIP = "Copier le code";
  static const String NUTRISCORE_ABOUT = "À propos du Nutri-Score";
  static const String ERROR_ICON_TEXT = "Erreur";
  static const String LOADING_TEXT = "Chargement...";
  static const String CLOSE = "Fermer";
  static const String PRODUCT_NOT_FOUND = "Produit non trouvé";
  static const String INVALID_FORMAT = "Format invalide";
}
