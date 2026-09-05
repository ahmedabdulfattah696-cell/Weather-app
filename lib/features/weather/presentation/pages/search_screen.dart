import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/constants/api_constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> recentSearches = ['Al Ain', 'Dubai', 'Abu Dhabi', 'Cairo'];

  // المدن المقترحة كأمثلة
  final List<Map<String, dynamic>> exampleCities = [
    {'name': 'New York', 'temp': '28°', 'icon': Icons.wb_sunny},
    {'name': 'London', 'temp': '20°', 'icon': Icons.cloud},
    {'name': 'Paris', 'temp': '22°', 'icon': Icons.wb_cloudy},
    {'name': 'Tokyo', 'temp': '26°', 'icon': Icons.wb_sunny},
    {'name': 'Sydney', 'temp': '18°', 'icon': Icons.cloud},
    {'name': 'Riyadh', 'temp': '31°', 'icon': Icons.wb_sunny},
    {'name': 'Cairo', 'temp': '29°', 'icon': Icons.wb_sunny},
    {'name': 'Berlin', 'temp': '19°', 'icon': Icons.cloud},
  ];

  final List<String> _savedCities = <String>[];
  final List<String> _recentHistory = <String>[];

  // تحويل القائمة لدعم حفظ (اسم العرض المترجم) و (الاسم الأصلي للبحث)
  final List<Map<String, String>> _filteredSuggestions = [];
  bool _isSearchingApi = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCities();
    _loadRecentSearches();
    _searchController.addListener(_updateSuggestions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // قاموس شامل لترجمة أسماء المدن والبلدان في شاشة البحث
  String _getLocalizedName(String name, bool isArabic) {
    if (!isArabic || name.trim().isEmpty) return name;

    final Map<String, String> translations = {
      // المدن
      'Al Ain': 'العين',
      'Abu Dhabi': 'أبوظبي',
      'Dubai': 'دبي',
      'Sharjah': 'الشارقة',
      'Ajman': 'عجمان',
      'Ras Al Khaimah': 'رأس الخيمة',
      'Fujairah': 'الفجيرة',
      'Umm Al Quwain': 'أم القيوين',
      'Cairo': 'القاهرة',
      'Riyadh': 'الرياض',
      'Mecca': 'مكة المكرمة',
      'Medina': 'المدينة المنورة',
      'London': 'لندن',
      'Paris': 'باريس',
      'New York': 'نيويورك',
      'Tokyo': 'طوكيو',
      'Berlin': 'برلين',
      'Sydney': 'سيدني',

      // البلدان
      'United Arab Emirates': 'الإمارات العربية المتحدة',
      'UAE': 'الإمارات',
      'Egypt': 'مصر',
      'Saudi Arabia': 'المملكة العربية السعودية',
      'United Kingdom': 'المملكة المتحدة',
      'UK': 'المملكة المتحدة',
      'France': 'فرنسا',
      'United States': 'الولايات المتحدة الأمريكية',
      'United States of America': 'الولايات المتحدة الأمريكية',
      'USA': 'أمريكا',
      'Japan': 'اليابان',
      'Germany': 'ألمانيا',
      'Canada': 'كندا',
      'Australia': 'أستراليا',
      'Italy': 'إيطاليا',
      'Spain': 'إسبانيا',
      'Turkey': 'تركيا',
    };

    return translations[name] ?? name;
  }

  Future<void> _loadSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_cities') ?? <String>[];
    if (!mounted) return;
    setState(() {
      _savedCities
        ..clear()
        ..addAll(saved);
    });
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList('recent_searches') ?? <String>[];
    if (!mounted) return;
    setState(() {
      _recentHistory
        ..clear()
        ..addAll(recent);
    });
  }

  Future<void> _saveCities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_cities', _savedCities);
  }

  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', _recentHistory);
  }

  void _updateSuggestions() async {
    final query = _searchController.text.trim();
    final isArabic = AppLanguageController.instance.isArabic;

    if (query.isEmpty) {
      setState(() {
        _filteredSuggestions.clear();
        _isSearchingApi = false;
      });
      return;
    }

    // البحث الديناميكي عبر الـ API لدعم العربي والانجليزي معاً
    if (query.length >= 2) {
      setState(() => _isSearchingApi = true);
      try {
        final dio = Dio();
        final response = await dio.get(
          'https://api.weatherapi.com/v1/search.json',
          queryParameters: {
            'key': ApiConstants.apiKey,
            'q': query,
            'lang': isArabic ? 'ar' : 'en',
          },
        );

        if (response.statusCode == 200 && mounted) {
          final List data = response.data;

          final apiCities = data.map<Map<String, String>>((item) {
            final name = item['name'].toString();
            final country = item['country'].toString();

            // ترجمة النتائج لعرضها باللغة المختارة
            final displayCity = _getLocalizedName(name, isArabic);
            final displayCountry = _getLocalizedName(country, isArabic);

            return {
              'display': country.isNotEmpty ? '$displayCity, $displayCountry' : displayCity,
              'value': name, // القيمة الأصلية للبحث للضمان
            };
          }).toList();

          setState(() {
            _filteredSuggestions
              ..clear()
              ..addAll(apiCities);
            _isSearchingApi = false;
          });
          return;
        }
      } catch (_) {
        if (mounted) setState(() => _isSearchingApi = false);
      }
    }

    // البحث المحلي (Fallback)
    final matches = <String>{
      ..._recentHistory,
      ...recentSearches,
      ...exampleCities.map((city) => city['name'].toString()),
    }.where((city) {
      // السماح بالبحث بالاسم الأصلي أو المترجم
      final localized = _getLocalizedName(city, isArabic).toLowerCase();
      return localized.contains(query.toLowerCase()) || city.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredSuggestions
        ..clear()
        ..addAll(matches.take(5).map((m) => {
          'display': _getLocalizedName(m, isArabic),
          'value': m,
        }));
      _isSearchingApi = false;
    });
  }

  Future<void> _addCityToSavedList(String city) async {
    final normalized = city.trim();
    if (normalized.isEmpty) return;
    final exists = _savedCities.any((item) => item.toLowerCase() == normalized.toLowerCase());
    if (!exists) {
      _savedCities.add(normalized);
      await _saveCities();
      if (mounted) setState(() {});
    }
  }

  Future<void> _addRecentSearch(String city) async {
    final normalized = city.trim();
    if (normalized.isEmpty) return;
    _recentHistory.removeWhere((item) => item.toLowerCase() == normalized.toLowerCase());
    _recentHistory.insert(0, normalized);
    if (_recentHistory.length > 6) {
      _recentHistory.removeRange(6, _recentHistory.length);
    }
    await _saveRecentSearches();
    if (mounted) setState(() {});
  }

  Future<void> _submitSearch([String? cityName]) async {
    final value = (cityName ?? _searchController.text).trim();
    if (value.isEmpty) {
      return;
    }
    await _addCityToSavedList(value);
    await _addRecentSearch(value);
    if (mounted) {
      _searchController.clear();
      _filteredSuggestions.clear();
      Navigator.pop(context, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = AppLanguageController.instance.isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            isArabic ? 'البحث عن مدينة' : 'Search City',
            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                isArabic ? 'ابحث عن أي مدينة في العالم...' : 'Search any city in the world...',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: isArabic ? 'أدخل اسم المدينة (مثال: باريس، طوكيو)...' : 'Enter city name (e.g. Paris, Tokyo)...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: () => _submitSearch(_searchController.text),
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (val) => _submitSearch(val),
              ),
              if (_filteredSuggestions.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.blueGrey.shade900 : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredSuggestions.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final suggestion = _filteredSuggestions[index];
                      return ListTile(
                        dense: true,
                        title: Text(suggestion['display'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                        leading: const Icon(Icons.location_on_outlined, size: 20, color: Colors.blue),
                        onTap: () => _submitSearch(suggestion['value']),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 25),
              Text(
                  isArabic ? 'المدن المحفوظة' : 'Saved Cities',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 12),
              if (_savedCities.isEmpty)
                Text(
                    isArabic ? 'لا توجد مدن محفوظة بعد.' : 'No saved cities yet.',
                    style: const TextStyle(color: Colors.grey)
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _savedCities.asMap().entries.map((entry) {
                    final city = entry.value;
                    return Dismissible(
                      key: ValueKey('${city}_${entry.key}'),
                      direction: isArabic ? DismissDirection.startToEnd : DismissDirection.endToStart,
                      background: Container(
                        padding: EdgeInsets.only(right: isArabic ? 0 : 16, left: isArabic ? 16 : 0),
                        alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        _savedCities.removeAt(entry.key);
                        await _saveCities();
                        if (mounted) setState(() {});
                      },
                      child: GestureDetector(
                        onTap: () => _submitSearch(city),
                        child: Chip(
                          label: Text(_getLocalizedName(city, isArabic)),
                          backgroundColor: isDark ? Colors.blueGrey.shade800 : Colors.grey[200],
                          labelStyle: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 25),
              Text(
                  isArabic ? 'عمليات البحث الأخيرة' : 'Recent Searches',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (_recentHistory.isEmpty ? recentSearches : _recentHistory).map((city) {
                  return GestureDetector(
                    onTap: () => _submitSearch(city),
                    child: Chip(
                      label: Text(_getLocalizedName(city, isArabic)),
                      backgroundColor: isDark ? Colors.blueGrey.shade800 : Colors.grey[200],
                      labelStyle: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 25),
              Text(
                  isArabic ? 'مدن مقترحة' : 'Example cities',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: exampleCities.length,
                  itemBuilder: (context, index) {
                    final city = exampleCities[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_getLocalizedName(city['name'], isArabic), style: const TextStyle(fontWeight: FontWeight.w500)),
                      onTap: () => _submitSearch(city['name'].toString()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(city['temp'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 10),
                          Icon(city['icon'], color: Colors.amber, size: 22),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}