import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../controllers/language_controller.dart';
import 'storage_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    final status = await Permission.notification.status;
    setState(() {
      _notificationsEnabled = status.isGranted;
    });
  }

  Future<void> _toggleNotifications() async {
    if (_notificationsEnabled) {
      openAppSettings();
    } else {
      final status = await Permission.notification.request();
      setState(() {
        _notificationsEnabled = status.isGranted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageController>(
      builder: (context, languageController, child) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pop();
            return false;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(languageController.translate('settings')),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.language),
                            title: Text(
                              languageController.translate('language'),
                            ),
                            trailing: DropdownButton<String>(
                              value:
                                  languageController.currentLocale.languageCode,
                              underline: const SizedBox(),
                              items: [
                                DropdownMenuItem(
                                  value: 'fr',
                                  child: Text(
                                    languageController.translate('french'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'en',
                                  child: Text(
                                    languageController.translate('english'),
                                  ),
                                ),
                              ],
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  languageController.setLanguage(newValue);
                                }
                              },
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.notifications),
                            title: Text(
                              languageController.translate('notifications'),
                            ),
                            subtitle: Text(
                              _notificationsEnabled
                                  ? languageController.translate(
                                    'notificationsEnabled',
                                  )
                                  : languageController.translate(
                                    'notificationsDisabled',
                                  ),
                            ),
                            trailing: Switch(
                              value: _notificationsEnabled,
                              onChanged: (bool value) => _toggleNotifications(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: Text(
                              languageController.translate('scanner'),
                            ),
                            subtitle: Text(
                              languageController.translate('scannerSettings'),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              // TODO: Scanner settings
                            },
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.notifications),
                            title: Text(
                              languageController.translate('notifications'),
                            ),
                            subtitle: Text(
                              languageController.translate(
                                'notificationsSettings',
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              // TODO: Notification settings
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.storage),
                            title: Text(
                              languageController.translate('storage'),
                            ),
                            subtitle: Text(
                              languageController.translate('storageSettings'),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          const StorageSettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
