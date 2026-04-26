import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), backgroundColor: Colors.transparent, elevation: 0),
      body: ListView(
        children: [
          _settingItem(Icons.notifications, 'Notifications', 'Enabled'),
          _settingItem(Icons.security, 'Privacy & Security', 'Everything looking good'),
          _settingItem(Icons.language, 'Language', 'English (US)'),
          _settingItem(Icons.dark_mode, 'Theme', 'Premium Dark'),
          _settingItem(Icons.storage, 'Data Usage', '34 MB used'),
        ],
      ),
    );
  }

  Widget _settingItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6A11CB)),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white24),
    );
  }
}
