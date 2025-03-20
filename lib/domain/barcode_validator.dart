import '../config/app_config.dart';

class BarcodeValidator {
  static String message(String barcode) {
    if (!isValidBarcode(barcode)) {
      return AppConfig.INVALID_BARCODE_MESSAGE;
    }

    if (isTunisianProduct(barcode)) {
      return AppConfig.TUNISIAN_PRODUCT_MESSAGE;
    } else {
      return AppConfig.NON_TUNISIAN_PRODUCT_MESSAGE;
    }
  }

  static bool isValidBarcode(String barcode) {
    // A simple check to ensure the barcode is numeric and has a valid length
    final regex = RegExp(
      r'^\d{8,13}$',
    ); // Common barcode lengths: 8 to 13 digits
    return regex.hasMatch(barcode);
  }

  static bool isTunisianProduct(String barcode) {
    return barcode.startsWith(AppConfig.TUNISIAN_BARCODE_PREFIX);
  }
}
