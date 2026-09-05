import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/theme_provider.dart';
import '../../providers/currency_provider.dart';
import '../../services/ad_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoSave = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoSave = prefs.getBool('auto_save') ?? true;
    });
  }

  Future<void> _toggleAutoSave(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_save', value);
    setState(() {
      _autoSave = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Preferences Section
          _buildSectionHeader('Preferences'),
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Auto-save calculations'),
                  subtitle: const Text('Save history automatically after calculation'),
                  value: _autoSave,
                  onChanged: _toggleAutoSave,
                ),
              ],
            ),
          ),
          
          // Currency Section
          _buildSectionHeader('Currency'),
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Indian Rupee (₹)'),
                  trailing: currencyProvider.symbol == '₹' ? const Icon(Icons.check, color: Colors.blue) : null,
                  onTap: () => currencyProvider.setCurrency('₹', 'en_IN'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('US Dollar (\$)'),
                  trailing: currencyProvider.symbol == '\$' ? const Icon(Icons.check, color: Colors.blue) : null,
                  onTap: () => currencyProvider.setCurrency('\$', 'en_US'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Euro (€)'),
                  trailing: currencyProvider.symbol == '€' ? const Icon(Icons.check, color: Colors.blue) : null,
                  onTap: () => currencyProvider.setCurrency('€', 'en_IE'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('British Pound (£)'),
                  trailing: currencyProvider.symbol == '£' ? const Icon(Icons.check, color: Colors.blue) : null,
                  onTap: () => currencyProvider.setCurrency('£', 'en_GB'),
                ),
              ],
            ),
          ),
          
          // Theme Section
          _buildSectionHeader('Appearance'),
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('System Default'),
                  value: ThemeMode.system,
                  groupValue: themeProvider.themeMode,
                  onChanged: (mode) {
                    if (mode != null) themeProvider.setThemeMode(mode);
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Light Mode'),
                  value: ThemeMode.light,
                  groupValue: themeProvider.themeMode,
                  onChanged: (mode) {
                    if (mode != null) themeProvider.setThemeMode(mode);
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark Mode'),
                  value: ThemeMode.dark,
                  groupValue: themeProvider.themeMode,
                  onChanged: (mode) {
                    if (mode != null) themeProvider.setThemeMode(mode);
                  },
                ),
              ],
            ),
          ),

          // About Section
          _buildSectionHeader('App Support'),
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.share, color: Colors.blue),
                  title: const Text('Share App'),
                  subtitle: const Text('Invite your friends & family'),
                  onTap: () {
                    Share.share('Check out Smart EMI Calculator - a beautiful, offline financial calculator app!');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: const Text('Rate App'),
                  subtitle: const Text('Provide feedback on Play Store'),
                  onTap: () {
                    // Mock link or open standard play store
                    launchUrl(Uri.parse('https://play.google.com/store'));
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.video_library, color: Colors.red),
                  title: const Text('Support Us'),
                  subtitle: const Text('Watch a short ad to support our developers'),
                  onTap: () {
                    AdService.instance.showRewardedAd(
                      onUserEarnedReward: (ad, reward) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Thank you so much for your support! You earned: ${reward.amount} ${reward.type}'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },

                      onAdClosed: () {
                        // Preload the next rewarded ad
                        AdService.instance.loadRewardedAd();
                      },
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: Colors.green),
                  title: const Text('Privacy Policy'),
                  onTap: () {
                    launchUrl(Uri.parse('https://example.com/privacy-policy'));
                  },
                ),
              ],
            ),
          ),


          _buildSectionHeader('Info'),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('App Version', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('1.0.0'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Smart EMI Calculator is a fast, offline tool to compute EMIs, compare loans, project investments, and do tax calculations with ease.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
