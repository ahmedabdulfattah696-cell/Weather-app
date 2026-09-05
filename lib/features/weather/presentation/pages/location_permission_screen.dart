import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/utils/app_colors.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import 'home_screen.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _isLoading = false;

  Future<void> _determinePositionAndNavigate(BuildContext context) async {
    if (_isLoading) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('الرجاء تفعيل خدمات الموقع (GPS) في الجهاز.')),
          );
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم رفض صلاحية الوصول للموقع.')),
          );
        }
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم رفض الوصول بشكل دائم. يمكنك تفعيله من إعدادات التطبيق.')),
          );
          await Geolocator.openAppSettings();
        }
        return;
      }

      if (!context.mounted) {
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
      );

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String cityName = 'Al Ain';
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        cityName = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? 'Al Ain';
      }

      if (!context.mounted) {
        return;
      }

      Navigator.pop(context);
      context.read<WeatherBloc>().add(GetCurrentWeatherEvent(cityName));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(cityName: cityName)),
      );
    } catch (_) {
      if (context.mounted) {
        Navigator.maybePop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = AppColors.backgroundGradientFor(Theme.of(context).brightness);
    final isArabic = AppLanguageController.instance.isArabic;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: gradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on, size: 80, color: Colors.white),
                ),
                const SizedBox(height: 35),
                Text(
                  isArabic ? 'السماح بالوصول للموقع' : 'Allow Location Access',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 15),
                Text(
                  isArabic
                      ? 'لإظهار معلومات الطقس بدقة، يرجى السماح بالوصول إلى الموقع.'
                      : 'To show you accurate weather information, please allow location access.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.4),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _isLoading ? null : () => _determinePositionAndNavigate(context),
                    child: Text(
                      _isLoading
                          ? (isArabic ? 'جارٍ التحقق...' : 'Checking location...')
                          : (isArabic ? 'السماح' : 'Allow Location'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white70),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                            );
                          },
                    child: Text(isArabic ? 'لاحقًا' : 'Not Now', style: const TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}