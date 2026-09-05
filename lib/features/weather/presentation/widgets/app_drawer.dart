import 'package:flutter/material.dart';
import '../../domain/entities/weather.dart';
import '../pages/search_screen.dart';
import '../pages/settings_screen.dart';
import '../pages/weather_details_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    this.weather,
    this.currentCity = 'Al Ain',
    this.favoriteCities = const [],
    this.currentThemeMode = ThemeMode.system,
    this.onThemeChanged,
    this.onSelectCity,
  });

  final Weather? weather;
  final String currentCity;
  final List<String> favoriteCities;
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode>? onThemeChanged;
  final ValueChanged<String>? onSelectCity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('Ahmad', style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: const Text('ahmad@gmail.com'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blue),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade400],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.blueGrey.shade900 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current City', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        currentCity,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search City'),
            onTap: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
              if (context.mounted && result != null && result is String && result.trim().isNotEmpty) {
                onSelectCity?.call(result.trim());
              }
            },
          ),
          if (favoriteCities.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: const Text('Favorites', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...favoriteCities.map(
                  (city) => ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: Text(city),
                onTap: () {
                  Navigator.pop(context);
                  onSelectCity?.call(city);
                },
              ),
            ),
          ],
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Weather Details'),
            enabled: weather != null,
            onTap: weather == null
                ? null
                : () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WeatherDetailsScreen(weather: weather!),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    currentThemeMode: currentThemeMode,
                    onThemeChanged: onThemeChanged,
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}