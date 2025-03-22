import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/language_controller.dart';

class StorageSettingsScreen extends StatefulWidget {
  const StorageSettingsScreen({Key? key}) : super(key: key);

  @override
  State<StorageSettingsScreen> createState() => _StorageSettingsScreenState();
}

class _StorageSettingsScreenState extends State<StorageSettingsScreen> {
  Map<String, dynamic> _storageItems = {};
  late SharedPreferences _prefs;
  int _totalSize = 0;

  @override
  void initState() {
    super.initState();
    _loadStorageItems();
  }

  Future<void> _loadStorageItems() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _storageItems = Map.fromEntries(
        _prefs.getKeys().map((key) => MapEntry(key, _prefs.get(key))),
      );
    });
    _calculateStorageSizes();
  }

  Future<void> _calculateStorageSizes() async {
    int total = 0;
    _storageItems.forEach((key, value) {
      total += _calculateItemSize(value);
    });
    setState(() {
      _totalSize = total;
    });
  }

  int _calculateItemSize(dynamic value) {
    if (value == null) return 0;
    return value.toString().length;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _deleteItem(String key) async {
    final lang = Provider.of<LanguageController>(context, listen: false);
    final itemSize = _calculateItemSize(_storageItems[key]);
    await _prefs.remove(key);
    await _loadStorageItems();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          lang
              .translate('freedSpace')
              .replaceAll('{size}', _formatSize(itemSize)),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _clearAllStorage() async {
    final lang = Provider.of<LanguageController>(context, listen: false);
    final totalSize = _totalSize; // Store current size before clearing
    await _prefs.clear();
    await _loadStorageItems();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          lang
              .translate('totalFreed')
              .replaceAll('{size}', _formatSize(totalSize)),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageController>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('storage')),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStorageItems,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearAllDialog(context, lang),
          ),
        ],
      ),
      body: Column(
        children: [
          // Storage Summary Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildStorageIndicator(
                lang.translate('totalStorage'),
                _totalSize,
                Colors.blue,
              ),
            ),
          ),
          // Storage Items List
          Expanded(
            child:
                _storageItems.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.storage_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            lang.translate('noStorageItems'),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _storageItems.length,
                      itemBuilder: (context, index) {
                        final key = _storageItems.keys.elementAt(index);
                        final value = _storageItems[key];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getIconForKey(key),
                                color: Colors.blue[700],
                                size: 24,
                              ),
                            ),
                            title: Text(
                              _formatKey(key),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(value ?? ''),
                                Text(
                                  _formatSize(_calculateItemSize(value)),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red[300],
                              ),
                              onPressed:
                                  () => _showDeleteDialog(context, lang, key),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageIndicator(String label, int size, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text(_formatSize(size))],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: size / (_totalSize + 1),
          backgroundColor: color.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  IconData _getIconForKey(String key) {
    if (key.contains('language')) return Icons.language;
    if (key.contains('notification')) return Icons.notifications;
    if (key.contains('scan')) return Icons.qr_code_scanner;
    return Icons.data_object;
  }

  String _formatKey(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    LanguageController lang,
    String key,
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
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteItem(key);
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

  Future<void> _showClearAllDialog(
    BuildContext context,
    LanguageController lang,
  ) {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(lang.translate('clearAllData')),
            content: Text(lang.translate('clearAllDataConfirm')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  lang.translate('cancel'),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _clearAllStorage(); // Use new method instead of direct clear
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  lang.translate('clearAll'),
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
    );
  }
}
