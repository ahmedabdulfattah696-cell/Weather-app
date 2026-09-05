import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/utils/app_colors.dart';
import '../../domain/entities/weather.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';
import '../widgets/weather_info_card.dart';
import '../widgets/app_drawer.dart';
import 'search_screen.dart';
import 'weather_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.cityName = 'Al Ain'});
  final String cityName;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Weather? _lastWeather;
  String _activeCity = 'Al Ain';
  String _lastValidCity = 'Al Ain';
  List<String> _favoriteCities = <String>[];

  @override
  void initState() {
    super.initState();
    _activeCity = widget.cityName;
    _loadFavoriteCities();
    _requestWeather(_activeCity);
  }

  Future<void> _loadFavoriteCities() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_cities') ?? <String>[];
    if (!mounted) return;
    setState(() => _favoriteCities = saved);
  }

  Future<void> _saveFavoriteCities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_cities', _favoriteCities);
  }

  Future<void> _onCitySelected(String cityName) async {
    final normalized = cityName.trim();
    if (normalized.isEmpty) return;
    if (!_favoriteCities.any((city) => city.toLowerCase() == normalized.toLowerCase())) {
      _favoriteCities = [..._favoriteCities, normalized];
      await _saveFavoriteCities();
    }
    if (mounted) {
      setState(() => _activeCity = normalized);
      _requestWeather(normalized);
    }
  }

  void _requestWeather(String cityName) {
    _activeCity = cityName;
    context.read<WeatherBloc>().add(GetCurrentWeatherEvent(cityName));
  }

  void _handleCityError(String message) {
    if (_activeCity != _lastValidCity) {
      setState(() => _activeCity = _lastValidCity);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  bool _hasValidWeather(Weather weather) {
    return weather.cityName.trim().isNotEmpty &&
        (weather.hourly.isNotEmpty || weather.daily.isNotEmpty || weather.temperature != 0.0);
  }

  IconData _conditionIcon(String description) {
    final value = description.toLowerCase();
    if (value.contains('rain') || value.contains('drizzle') || value.contains('أمطار')) return Icons.grain;
    if (value.contains('cloud') || value.contains('غائم')) return Icons.cloud;
    if (value.contains('snow') || value.contains('ثلج')) return Icons.ac_unit;
    if (value.contains('storm') || value.contains('thunder') || value.contains('عاصفة')) return Icons.thunderstorm;
    if (value.contains('mist') || value.contains('fog') || value.contains('ضباب')) return Icons.foggy;
    return Icons.wb_sunny;
  }

  String _getLocalizedName(String name, bool isArabic) {
    if (!isArabic || name.trim().isEmpty) return name;

    final Map<String, String> translations = {
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
    };

    return translations[name] ?? name;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final backgroundGradient = AppColors.backgroundGradientFor(brightness);
    final isArabic = AppLanguageController.instance.isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: AppDrawer(
          weather: _lastWeather,
          currentCity: _activeCity,
          favoriteCities: _favoriteCities,
          currentThemeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
          onThemeChanged: (_) {},
          onSelectCity: (city) {
            _onCitySelected(city);
          },
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: backgroundGradient,
          ),
          child: SafeArea(
            child: BlocListener<WeatherBloc, WeatherState>(
              listener: (context, state) {
                if (state is WeatherLoaded) {
                  setState(() {
                    _lastWeather = state.weather;
                    _lastValidCity = state.weather.cityName;
                    _activeCity = state.weather.cityName;
                  });
                  return;
                }
                if (state is WeatherError) {
                  _handleCityError(state.message);
                }
              },
              child: BlocBuilder<WeatherBloc, WeatherState>(
                builder: (context, state) {
                  if (state is WeatherLoading) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  if (state is WeatherLoaded) {
                    return RefreshIndicator(
                      onRefresh: () async => _requestWeather(state.weather.cityName),
                      color: Colors.white,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLiquidGlassAppBar(context, state.weather.cityName, isArabic),
                            const SizedBox(height: 16),
                            if (_favoriteCities.isNotEmpty) _buildFavoriteCitiesRow(),
                            const SizedBox(height: 20),
                            _buildMainWeather(context, state.weather, isArabic),
                            const SizedBox(height: 30),
                            _buildTodayForecast(state.weather, isArabic),
                            const SizedBox(height: 20),
                            _buildWeeklyForecast(state.weather, isArabic),
                          ],
                        ),
                      ),
                    );
                  }
                  if (state is WeatherError) {
                    if (_lastWeather != null) {
                      return RefreshIndicator(
                        onRefresh: () async => _requestWeather(_lastValidCity),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLiquidGlassAppBar(context, _lastValidCity, isArabic),
                              const SizedBox(height: 16),
                              if (_favoriteCities.isNotEmpty) _buildFavoriteCitiesRow(),
                              const SizedBox(height: 20),
                              _buildMainWeather(context, _lastWeather!, isArabic),
                              const SizedBox(height: 30),
                              _buildTodayForecast(_lastWeather!, isArabic),
                              const SizedBox(height: 20),
                              _buildWeeklyForecast(_lastWeather!, isArabic),
                            ],
                          ),
                        ),
                      );
                    }
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.message,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => _requestWeather(_lastValidCity),
                              icon: const Icon(Icons.refresh),
                              label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteCitiesRow() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _favoriteCities.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final city = _favoriteCities[index];
          final isSelected = city.toLowerCase() == _activeCity.toLowerCase();
          final isArabic = AppLanguageController.instance.isArabic;
          final localizedCityName = _getLocalizedName(city, isArabic);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _onCitySelected(city),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isSelected ? 0.5 : 0.2),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_city,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      localizedCityName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiquidGlassAppBar(BuildContext context, String cityName, bool isArabic) {
    final rawCountry = _lastWeather?.country ?? '';
    final localizedCity = _getLocalizedName(cityName, isArabic);
    final localizedCountry = _getLocalizedName(rawCountry, isArabic);

    final displayLocation = localizedCountry.isNotEmpty
        ? '$localizedCity, $localizedCountry'
        : localizedCity;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 26),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    displayLocation,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 26),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
              if (!context.mounted || result == null || result is! String || result.trim().isEmpty) {
                return;
              }
              _onCitySelected(result.trim());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainWeather(BuildContext context, Weather weather, bool isArabic) {
    final conditionIcon = _conditionIcon(weather.description);
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (!_hasValidWeather(weather)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isArabic ? 'بيانات الطقس غير متوفرة بعد.' : 'Weather data is not available yet.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => WeatherDetailsScreen(weather: weather)),
            );
          },
          child: Center(
            child: Column(
              children: [
                Text(
                  weather.date,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${weather.temperature.round()}°',
                      style: const TextStyle(
                        fontSize: 85,
                        color: Colors.white,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Icon(conditionIcon, color: Colors.amber, size: 60),
                  ],
                ),
                Text(
                  weather.description,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              WeatherInfoCard(label: isArabic ? 'الإحساس' : 'Feels like', value: '${weather.feelsLike.round()}°'),
              WeatherInfoCard(label: isArabic ? 'الرطوبة' : 'Humidity', value: '${weather.humidity}%'),
              WeatherInfoCard(label: isArabic ? 'الرياح' : 'Wind', value: '${weather.windSpeed.round()} km/h'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodayForecast(Weather weather, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? "توقعات اليوم" : "Today's Forecast",
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weather.hourly.length > 10 ? 10 : weather.hourly.length,
            itemBuilder: (context, index) {
              final hourly = weather.hourly[index];
              final hourIcon = _conditionIcon(hourly.icon.isNotEmpty ? hourly.icon : 'sunny');
              return Container(
                width: 65,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: index == 0
                      ? Colors.white.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      index == 0 ? (isArabic ? 'الآن' : 'Now') : hourly.time,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Icon(hourIcon, color: Colors.amber, size: 22),
                    Text(
                      '${hourly.temp.round()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyForecast(Weather weather, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'توقعات 7 أيام' : '7-Day Forecast',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: weather.daily.length,
            itemBuilder: (context, index) {
              final daily = weather.daily[index];
              final dailyIcon = _conditionIcon(daily.icon.isNotEmpty ? daily.icon : 'sunny');
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        daily.day,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    Icon(dailyIcon, color: Colors.amber, size: 20),
                    Text(
                      '${daily.maxTemp.round()}° / ${daily.minTemp.round()}°',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}