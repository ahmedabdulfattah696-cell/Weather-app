# Weather App

A Flutter weather application with weather forecasts, city search, onboarding, location-based weather discovery, saved cities, dark mode, and settings persistence.

## Features
- Real-time weather lookup using WeatherAPI
- Current weather and 7-day forecast
- Search by city
- Save favorite cities locally
- Onboarding and location permission flow
- Dark mode and light mode
- Persistent app settings using SharedPreferences
- Retry and pull-to-refresh behavior

## Stack
- Flutter
- Dart
- BLoC
- Dio
- Dependency Injection via GetIt
- SharedPreferences

## Run locally
1. Install Flutter SDK.
2. Install dependencies:
   flutter pub get
3. Run the app:
   flutter run

Optional API key override:
   flutter run --dart-define=WEATHER_API_KEY=your_api_key

## Notes
The app currently uses WeatherAPI to fetch weather data. If the API key is not provided via `--dart-define`, it falls back to the default demo key in `lib/core/constants/api_constants.dart`.
