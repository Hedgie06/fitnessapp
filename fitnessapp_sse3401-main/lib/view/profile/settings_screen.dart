import 'package:flutter/material.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  static String routeName = "/SettingsScreen";
  
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool useMetricSystem = true;
  bool darkMode = false;
  bool autoDownload = true;
  String selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      useMetricSystem = prefs.getBool('useMetricSystem') ?? true;
      darkMode = prefs.getBool('darkMode') ?? false;
      autoDownload = prefs.getBool('autoDownload') ?? true;
      selectedLanguage = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useMetricSystem', useMetricSystem);
    await prefs.setBool('darkMode', darkMode);
    await prefs.setBool('autoDownload', autoDownload);
    await prefs.setString('language', selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.blackColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: "General",
              children: [
                _buildSwitchTile(
                  title: "Use Metric System",
                  subtitle: "Switch between metric and imperial units",
                  value: useMetricSystem,
                  onChanged: (value) {
                    setState(() {
                      useMetricSystem = value;
                      _saveSettings();
                    });
                  },
                ),
                _buildDivider(),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: "App Settings",
              children: [
                _buildSwitchTile(
                  title: "Auto-download Workouts",
                  subtitle: "Download workout content automatically",
                  value: autoDownload,
                  onChanged: (value) {
                    setState(() {
                      autoDownload = value;
                      _saveSettings();
                    });
                  },
                ),
                _buildDivider(),
                _buildLanguageSelector(),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: "Storage",
              children: [
                ListTile(
                  title: const Text("Clear Cache"),
                  subtitle: const Text("Free up space by clearing cached data"),
                  trailing: TextButton(
                    onPressed: () {
                      // Show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Clear Cache"),
                          content: const Text("Are you sure you want to clear the cache?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                // Implement cache clearing logic
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Cache cleared")),
                                );
                              },
                              child: const Text("Clear"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text("CLEAR"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.blackColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primaryColor1,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildLanguageSelector() {
    return ListTile(
      title: const Text("Language"),
      subtitle: Text(selectedLanguage),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Select Language"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                "English",
                "Spanish",
                "French",
                "German"
              ].map((language) => ListTile(
                title: Text(language),
                onTap: () {
                  setState(() {
                    selectedLanguage = language;
                    _saveSettings();
                  });
                  Navigator.pop(context);
                },
              )).toList(),
            ),
          ),
        );
      },
    );
  }
}
