import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/language_controller.dart';
import '../../services/history_manager.dart';
import '../../domain/models/scan_history.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../config/app_config.dart';
import '../../data/api/product_api.dart';
import '../screens/product_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  final HistoryManager _historyManager = HistoryManager();
  List<ScanHistory> _history = [];
  late AnimationController _animationController;
  late LanguageController _languageController;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageController = Provider.of<LanguageController>(
      context,
      listen: false,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _animationController.dispose();
    super.dispose();
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

  Future<void> _handleLookupProduct(ScanHistory item) async {
    Navigator.pop(context);
    try {
      final product = await ProductApi.getProduct(item.code);
      if (_isDisposed) return;

      if (product != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProductDetailsScreen(
                  product: product,
                  countryName: item.country,
                  barcodeType: item.format,
                ),
          ),
        );
      } else {
        _showError('noDetails', Colors.orange);
      }
    } catch (e) {
      if (!_isDisposed) {
        _showError('error', Colors.red);
      }
    }
  }

  void _showError(String key, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_languageController.translate(key)),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _showDetailsBottomSheet(BuildContext context, ScanHistory item) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _languageController.translate('productDetails'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: Text(_languageController.translate('lookupProduct')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _handleLookupProduct(item),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageController>(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.translate('history')),
            Text(
              '${_history.length} ${lang.translate("scannedItems")}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearHistoryDialog(context, lang),
              tooltip: lang.translate('clearHistory'),
            ),
        ],
      ),
      body:
          _history.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      lang.translate('noHistory'),
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lang.translate('startScanning'),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : AnimatedList(
                initialItemCount: _history.length,
                itemBuilder: (context, index, animation) {
                  final item = _history[index];
                  return SlideTransition(
                    position: animation.drive(
                      Tween(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).chain(CurveTween(curve: Curves.easeOutCubic)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: _buildHistoryCard(item, lang),
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildHistoryCard(ScanHistory item, LanguageController lang) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.code,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildIconButton(
                          Icons.copy_rounded,
                          () => _copyToClipboard(item.code),
                          Colors.blue,
                        ),
                        _buildIconButton(
                          Icons.delete_outline_rounded,
                          () => _showDeleteDialog(context, lang, item.code),
                          Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildChip(item.format, Icons.qr_code_2, Colors.blue),
                          const SizedBox(width: 8),
                          _buildChip(
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
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade200, Colors.purple.shade400],
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _handleDirectProductDetails(item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat(
                                  'dd/MM/yyyy HH:mm',
                                ).format(item.scanDate),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                lang.translate('seeDetails'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDirectProductDetails(ScanHistory item) async {
    try {
      final product = await ProductApi.getProduct(item.code);
      if (!mounted) return;

      if (product != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProductDetailsScreen(
                  product: product,
                  countryName: item.country,
                  barcodeType: item.format,
                ),
          ),
        );
      } else {
        _showError('noDetails', Colors.orange);
      }
    } catch (e) {
      if (!mounted) return;
      _showError('error', Colors.red);
    }
  }

  Widget _buildIconButton(
    IconData icon,
    VoidCallback onPressed,
    MaterialColor color,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color[400], size: 20),
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, MaterialColor color) {
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
