import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/localization/app_language.dart';
import '../models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getCurrentWeather(String cityName);
  Future<List<String>> searchCities(String query);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final Dio dio;
  WeatherRemoteDataSourceImpl({required this.dio});

  @override
  Future<WeatherModel> getCurrentWeather(String cityName) async {
    try {
      // التحقق مما إذا كانت اللغة الحالية هي العربية لإرسالها للـ API
      final bool isArabic = AppLanguageController.instance.isArabic;

      final response = await dio.get(
        'https://api.weatherapi.com/v1/forecast.json',
        queryParameters: {
          'key': ApiConstants.apiKey,
          'q': cityName,
          'days': 7,
          'aqi': 'yes',
          'lang': isArabic ? 'ar' : 'en', // <-- إرسال اللغة المطلوبة للخادم
        },
      );

      if (response.statusCode == 200) {
        final payload = response.data;
        if (payload is Map<String, dynamic> && payload.containsKey('error')) {
          final errorMessage = payload['error']?['message'] ?? 'No matching location found';
          throw Exception(errorMessage);
        }
        return WeatherModel.fromJson(payload);
      } else {
        throw Exception('Server Error');
      }
    } catch (e) {
      throw Exception('Failed to load weather data: $e');
    }
  }

  @override
  Future<List<String>> searchCities(String query) async {
    try {
      final response = await dio.get(
        'https://api.weatherapi.com/v1/search.json',
        queryParameters: {
          'key': ApiConstants.apiKey,
          'q': query,
        },
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((item) => '${item['name']}, ${item['country']}').toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}