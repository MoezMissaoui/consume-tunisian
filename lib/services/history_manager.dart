import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/scan_history.dart';

class HistoryManager {
  static const String HISTORY_KEY = 'scan_history';
  static const int MAX_HISTORY_ITEMS = 10;

  Future<bool> isCodeAlreadySaved(String code) async {
    final history = await getHistory();
    return history.any((item) => item.code == code);
  }

  Future<void> addScan(String code, String format, String country) async {
    // Check if code already exists
    if (await isCodeAlreadySaved(code)) {
      return; // Don't save if already exists
    }

    final prefs = await SharedPreferences.getInstance();
    List<ScanHistory> history = await getHistory();

    // Add new scan at the beginning (FIFO)
    history.insert(
      0,
      ScanHistory(
        code: code,
        format: format,
        country: country,
        scanDate: DateTime.now(),
      ),
    );

    // Keep only the last MAX_HISTORY_ITEMS items
    if (history.length > MAX_HISTORY_ITEMS) {
      history = history.take(MAX_HISTORY_ITEMS).toList();
    }

    // Save to SharedPreferences
    final historyJson = history.map((item) => item.toJson()).toList();
    await prefs.setString(HISTORY_KEY, jsonEncode(historyJson));
  }

  Future<void> deleteCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    List<ScanHistory> history = await getHistory();

    history.removeWhere((item) => item.code == code);

    final historyJson = history.map((item) => item.toJson()).toList();
    await prefs.setString(HISTORY_KEY, jsonEncode(historyJson));
  }

  Future<List<ScanHistory>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString(HISTORY_KEY);
    if (historyString == null) return [];

    final historyJson = jsonDecode(historyString) as List;
    return historyJson.map((item) => ScanHistory.fromJson(item)).toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(HISTORY_KEY);
  }
}
