import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finsense/services/storage/secure_storage_service.dart';
import 'package:finsense/shared/widgets/gradient_button.dart';
import 'package:finsense/shared/widgets/global_drawer.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _keyController = TextEditingController();

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  void _saveKey() async {
    final storage = ref.read(secureStorageProvider);
    await storage.saveApiKey(_keyController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API Key Saved Successfully')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  void _loadKey() async {
    final storage = ref.read(secureStorageProvider);
    final key = await storage.getApiKey();
    if (key != null) {
      _keyController.text = key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const GlobalDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gemini 3 API Setup',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'To use FinSense AI features (Tips, Goals, and Chat), please provide your Google Gemini API Key. This relies on the gemini-3-flash-preview model.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _keyController,
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: 'AIzaSy...',
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: 'Save Key Securely',
                onPressed: _saveKey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
