import 'package:equatable/equatable.dart';

class HourlyForecast extends Equatable {
  final String time;
  final double temp;
  final String icon;

  const HourlyForecast({required this.time, required this.temp, required this.icon});

  @override
  List<Object?> get props => [time, temp, icon];
}

class DailyForecast extends Equatable {
  final String day;
  final double maxTemp;
  final double minTemp;
  final String icon;

  const DailyForecast({required this.day, required this.maxTemp, required this.minTemp, required this.icon});

  @override
  List<Object?> get props => [day, maxTemp, minTemp, icon];
}

class Weather extends Equatable {
  final String cityName;
  final String country;
  final double temperature;
  final String description;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String date;
  final double uvIndex;
  final double visibility;
  final int pressure;
  final String sunrise;
  final String sunset;
  final double dewPoint;
  final int airQualityIndex;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  const Weather({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.description,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.date,
    required this.uvIndex,
    required this.visibility,
    required this.pressure,
    required this.sunrise,
    required this.sunset,
    required this.dewPoint,
    required this.airQualityIndex,
    required this.hourly,
    required this.daily,
  });

  @override
  List<Object?> get props => [
    cityName, country, temperature, description, feelsLike,
    humidity, windSpeed, date, uvIndex, visibility, pressure,
    sunrise, sunset, dewPoint, airQualityIndex, hourly, daily
  ];
}