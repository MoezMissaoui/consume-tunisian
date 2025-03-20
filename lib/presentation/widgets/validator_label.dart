import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class ValidatorLabel extends StatelessWidget {
  final bool isValidBarcode;
  final String message;

  const ValidatorLabel({
    Key? key,
    required this.isValidBarcode,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color:
            isValidBarcode
                ? AppConfig.COLOR_SUCCESS.withOpacity(0.2)
                : AppConfig.COLOR_FAILER.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color:
              isValidBarcode ? AppConfig.COLOR_SUCCESS : AppConfig.COLOR_FAILER,
          width: 2,
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          color:
              isValidBarcode ? AppConfig.COLOR_SUCCESS : AppConfig.COLOR_FAILER,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
