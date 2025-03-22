import 'package:consume_tunisian/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/language_controller.dart';
import 'presentation/screens/barcode_scanner_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance(); // Initialize shared preferences

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageController>(
      builder: (context, languageController, child) {
        return MaterialApp(
          locale: languageController.currentLocale,
          title: AppConfig.APP_TITLE,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          home: BarcodeScannerScreen(),
        );
      },
    );
  }
}
