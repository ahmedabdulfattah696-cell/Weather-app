class ApiConstants {
  static const String baseUrl = 'https://api.weatherapi.com/v1';

  static const String apiKey = String.fromEnvironment(
    'WEATHER_API_KEY',
    defaultValue: '',
  );
}