import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.currentThemeMode = ThemeMode.system,
    this.onThemeChanged,
  });

  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode>? onThemeChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isCelsius = true;
  bool dailyForecastNotification = true;
  bool severeWeatherAlerts = true;
  late ThemeMode _selectedThemeMode;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _selectedThemeMode = widget.currentThemeMode;
    _selectedLanguage = AppLanguageController.instance.language;
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('app_language') ?? AppLanguageController.instance.language;
    if (!mounted) return;
    setState(() => _selectedLanguage = language);
  }

  Future<void> _setLanguage(String language) async {
    _selectedLanguage = language;
    await AppLanguageController.instance.setLanguage(language);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', language);
    if (mounted) setState(() {});
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    _selectedThemeMode = mode;
    widget.onThemeChanged?.call(mode);
    await AppThemeController.instance.setThemeMode(mode);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = AppLanguageController.instance.isArabic;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isArabic ? 'الإعدادات' : 'Settings',
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(isArabic ? 'الوحدات' : 'Units', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isArabic ? 'درجة الحرارة' : 'Temperature', style: const TextStyle(fontSize: 16)),
              ToggleButtons(
                isSelected: [isCelsius, !isCelsius],
                onPressed: (index) {
                  setState(() {
                    isCelsius = index == 0;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                selectedColor: Colors.white,
                fillColor: Colors.blue,
                color: isDark ? Colors.white : Colors.black,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 35),
                children: const [Text('°C'), Text('°F')],
              ),
            ],
          ),
          const Divider(height: 30),
          Text(isArabic ? 'الإشعارات' : 'Notifications', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: Text(isArabic ? 'التوقعات اليومية' : 'Daily Forecast'),
            value: dailyForecastNotification,
            onChanged: (val) => setState(() => dailyForecastNotification = val),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: Text(isArabic ? 'تنبيهات الطقس الشديدة' : 'Severe Weather Alerts'),
            value: severeWeatherAlerts,
            onChanged: (val) => setState(() => severeWeatherAlerts = val),
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(height: 30),
          Text(isArabic ? 'المظهر' : 'Appearance', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment<ThemeMode>(value: ThemeMode.system, label: Text(isArabic ? 'النظام' : 'System')),
              ButtonSegment<ThemeMode>(value: ThemeMode.light, label: Text(isArabic ? 'فاتح' : 'Light')),
              ButtonSegment<ThemeMode>(value: ThemeMode.dark, label: Text(isArabic ? 'داكن' : 'Dark')),
            ],
            selected: {_selectedThemeMode},
            onSelectionChanged: (selection) => _setThemeMode(selection.first),
          ),
          const Divider(height: 30),
          Text(isArabic ? 'اللغة' : 'Localization', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment<String>(value: 'English', label: Text('English')),
              ButtonSegment<String>(value: 'Arabic', label: Text('Arabic')),
            ],
            selected: {_selectedLanguage},
            onSelectionChanged: (selection) => _setLanguage(selection.first),
          ),
          const Divider(height: 30),
          Text(isArabic ? 'أخرى' : 'Other', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ListTile(
            title: Text(isArabic ? 'حول التطبيق' : 'About App'),
            trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
            contentPadding: EdgeInsets.zero,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}