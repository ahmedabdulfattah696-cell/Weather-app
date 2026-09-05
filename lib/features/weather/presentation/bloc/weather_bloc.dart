import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_current_weather.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final GetCurrentWeather getCurrentWeather;

  WeatherBloc({required this.getCurrentWeather}) : super(WeatherInitial()) {
    on<GetCurrentWeatherEvent>((event, emit) async {
      emit(WeatherLoading());
      final failureOrWeather = await getCurrentWeather.execute(event.cityName);

      failureOrWeather.fold(
            (failure) => emit(WeatherError(failure.message)),
            (weather) => emit(WeatherLoaded(weather)),
      );
    });
  }
}