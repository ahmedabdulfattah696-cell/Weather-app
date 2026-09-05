import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'features/weather/data/datasources/weather_remote_data_source.dart';
import 'features/weather/data/repositories/weather_repository_impl.dart';
import 'features/weather/domain/repositories/weather_repository.dart';
import 'features/weather/domain/usecases/get_current_weather.dart';
import 'features/weather/presentation/bloc/weather_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc
  sl.registerFactory(() => WeatherBloc(getCurrentWeather: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetCurrentWeather(sl()));

  // Repository
  sl.registerLazySingleton<WeatherRepository>(
        () => WeatherRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<WeatherRemoteDataSource>(
        () => WeatherRemoteDataSourceImpl(dio: sl()),
  );

  // External
  sl.registerLazySingleton(() => Dio());
}