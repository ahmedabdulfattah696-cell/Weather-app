import '../../domain/entities/weather.dart';

class WeatherModel extends Weather {
  const WeatherModel({
    required super.cityName,
    required super.country,
    required super.temperature,
    required super.description,
    required super.feelsLike,
    required super.humidity,
    required super.windSpeed,
    required super.date,
    required super.uvIndex,
    required super.visibility,
    required super.pressure,
    required super.sunrise,
    required super.sunset,
    required super.dewPoint,
    required super.airQualityIndex,
    required super.hourly,
    required super.daily,
  });

  Map<String, dynamic> toJson() {
    return {
      'location': {
        'name': cityName,
        'country': country,
        'localtime': date,
      },
      'current': {
        'temp_c': temperature,
        'condition': {'text': description},
        'feelslike_c': feelsLike,
        'humidity': humidity,
        'wind_kph': windSpeed,
        'uv': uvIndex,
        'vis_km': visibility,
        'pressure_mb': pressure,
        'dewpoint_c': dewPoint,
        'air_quality': {'pm2_5': airQualityIndex},
      },
      'forecast': {
        'forecastday': [
          {
            'date': date,
            'day': {
              'maxtemp_c': daily.isNotEmpty ? daily.first.maxTemp : temperature,
              'mintemp_c': daily.isNotEmpty ? daily.first.minTemp : temperature,
              'condition': {'text': description},
            },
            'astro': {'sunrise': sunrise, 'sunset': sunset},
            'hour': hourly.map((hour) => {
              'time': '2024-01-01 ${hour.time}',
              'temp_c': hour.temp,
              'condition': {'text': hour.icon},
            }).toList(),
          },
          ...daily.skip(1).map((day) => {
            'date': day.day,
            'day': {
              'maxtemp_c': day.maxTemp,
              'mintemp_c': day.minTemp,
              'condition': {'text': day.icon},
            },
          }),
        ],
      },
    };
  }

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? {};
    final current = json['current'] ?? {};
    final forecast = json['forecast']?['forecastday'] ?? [];

    List<HourlyForecast> hourlyList = [];
    if (forecast.isNotEmpty) {
      final hours = forecast[0]['hour'] ?? [];
      for (var h in hours) {
        String timeStr = h['time'].toString().split(' ').last;
        hourlyList.add(HourlyForecast(
          time: timeStr,
          temp: (h['temp_c'] as num).toDouble(),
          icon: h['condition']['text'] ?? '',
        ));
      }
    }

    List<DailyForecast> dailyList = [];
    for (var d in forecast) {
      String dateStr = d['date'] ?? '';
      final dayData = d['day'] ?? {};
      dailyList.add(DailyForecast(
        day: dateStr,
        maxTemp: (dayData['maxtemp_c'] as num).toDouble(),
        minTemp: (dayData['mintemp_c'] as num).toDouble(),
        icon: dayData['condition']['text'] ?? '',
      ));
    }

    final astro = forecast.isNotEmpty ? forecast[0]['astro'] ?? {} : {};

    return WeatherModel(
      cityName: location['name'] ?? '',
      country: location['country'] ?? '',
      temperature: (current['temp_c'] as num?)?.toDouble() ?? 0.0,
      description: current['condition']?['text'] ?? '',
      feelsLike: (current['feelslike_c'] as num?)?.toDouble() ?? 0.0,
      humidity: (current['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (current['wind_kph'] as num?)?.toDouble() ?? 0.0,
      date: location['localtime'] ?? '',
      uvIndex: (current['uv'] as num?)?.toDouble() ?? 0.0,
      visibility: (current['vis_km'] as num?)?.toDouble() ?? 0.0,
      pressure: (current['pressure_mb'] as num?)?.toInt() ?? 0,
      sunrise: astro['sunrise'] ?? '06:00 AM',
      sunset: astro['sunset'] ?? '06:00 PM',
      dewPoint: (current['dewpoint_c'] as num?)?.toDouble() ?? 10.0,
      airQualityIndex: (current['air_quality']?['pm2_5'] as num?)?.toInt() ?? 42,
      hourly: hourlyList,
      daily: dailyList,
    );
  }
}