import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/language_controller.dart';
import '../../services/history_manager.dart';
import '../../domain/models/scan_history.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../config/app_config.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryManager _historyManager = HistoryManager();
  List<ScanHistory> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _historyManager.getHistory();
    setState(() => _history = history);
  }

  Future<void> _clearHistory() async {
    await _historyManager.clearHistory();
    _loadHistory();
  }

  Future<void> _deleteCode(String code) async {
    await _historyManager.deleteCode(code);
    _loadHistory();
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  MaterialColor _getCountryColor(String country) {
    return country.contains(AppConfig.USER_COUNTRY) ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageController>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('history')),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearHistoryDialog(context, lang),
            ),
        ],
      ),
      body:
          _history.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      lang.translate('noHistory'),
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Content area
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.code,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 18),
                                    onPressed:
                                        () => _copyToClipboard(item.code),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red[300],
                                    ),
                                    onPressed:
                                        () => _showDeleteDialog(
                                          context,
                                          lang,
                                          item.code,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildModernChip(
                                      item.format,
                                      Icons.qr_code_2,
                                      Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildModernChip(
                                      item.country,
                                      Icons.location_on,
                                      _getCountryColor(item.country),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Date row at bottom
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.purple[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat(
                                  'dd/MM/yyyy HH:mm',
                                ).format(item.scanDate),
                                style: TextStyle(
                                  color: Colors.purple[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildModernChip(String label, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color[700]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color[700], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearHistoryDialog(
    BuildContext context,
    LanguageController lang,
  ) {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(lang.translate('clearHistory')),
            content: Text(lang.translate('clearHistoryConfirm')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  lang.translate('cancel'),
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _clearHistory();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  lang.translate('clear'),
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    LanguageController lang,
    String code,
  ) {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(lang.translate('deleteItem')),
            content: Text(lang.translate('deleteItemConfirm')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  lang.translate('cancel'),
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteCode(code);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  lang.translate('delete'),
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
    );
  }
}
