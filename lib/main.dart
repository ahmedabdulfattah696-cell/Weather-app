import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/localization/app_language.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_colors.dart';
import 'features/weather/presentation/bloc/weather_bloc.dart';
import 'features/weather/presentation/pages/home_screen.dart';
import 'features/weather/presentation/pages/onboarding_screen.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await AppThemeController.instance.initialize();
  await AppLanguageController.instance.initialize();
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstTime = prefs.getBool('is_first_time') ?? true;
  runApp(MyApp(isFirstTime: isFirstTime));
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;
  const MyApp({
    super.key,
    required this.isFirstTime,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<WeatherBloc>()),
      ],
      child: AnimatedBuilder(
        animation: Listenable.merge([
          AppThemeController.instance,
          AppLanguageController.instance,
        ]),
        builder: (_, _) {
          final isArabic = AppLanguageController.instance.isArabic;
          return MaterialApp(
            title: 'Weather App',
            debugShowCheckedModeBanner: false,
            themeMode: AppThemeController.instance.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.white,
              fontFamily: 'Roboto',
              colorScheme: const ColorScheme.light(
                primary: AppColors.primaryColor,
                secondary: AppColors.accentColor,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF0F172A),
              fontFamily: 'Roboto',
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primaryColor,
                secondary: AppColors.accentColor,
              ),
            ),
            locale: isArabic ? const Locale('ar') : const Locale('en'),
            supportedLocales: const [
              Locale('en', ''),
              Locale('ar', ''),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: isFirstTime ? const OnboardingScreen() : const HomeScreen(),
          );
        },
      ),
    );
  }
}