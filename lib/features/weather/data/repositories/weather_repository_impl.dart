import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_data_source.dart';
import '../models/weather_model.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;

  WeatherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Weather>> getCurrentWeather(String cityName) async {
    try {
      final remoteWeather = await remoteDataSource.getCurrentWeather(cityName);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'cache_weather_${cityName.trim().toLowerCase()}',
        jsonEncode(remoteWeather.toJson()),
      );
      return Right(remoteWeather);
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final cachedRaw = prefs.getString('cache_weather_${cityName.trim().toLowerCase()}');
      if (cachedRaw != null && cachedRaw.isNotEmpty) {
        try {
          final cachedMap = jsonDecode(cachedRaw) as Map<String, dynamic>;
          return Right(WeatherModel.fromJson(cachedMap));
        } catch (_) {}
      }
      return const Left(ServerFailure('تعذر جلب بيانات الطقس من الخادم'));
    }
  }
}