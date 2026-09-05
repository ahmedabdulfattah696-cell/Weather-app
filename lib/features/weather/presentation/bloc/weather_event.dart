import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

class GetCurrentWeatherEvent extends WeatherEvent {
  final String cityName;
  const GetCurrentWeatherEvent(this.cityName);

  @override
  List<Object> get props => [cityName];
}