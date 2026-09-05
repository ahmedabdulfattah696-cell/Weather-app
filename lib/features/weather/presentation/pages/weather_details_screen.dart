import 'package:flutter/material.dart';
import '../../domain/entities/weather.dart';

class WeatherDetailsScreen extends StatelessWidget {
  const WeatherDetailsScreen({super.key, required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final uvLabel = weather.uvIndex < 3
        ? 'Low'
        : weather.uvIndex < 6
            ? 'Moderate'
            : weather.uvIndex < 8
                ? 'High'
                : 'Very High';

    final airQualityLabel = weather.airQualityIndex < 50
        ? 'Good'
        : weather.airQualityIndex < 100
            ? 'Moderate'
            : 'Unhealthy';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Weather Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildDetailCard('UV Index', '${weather.uvIndex.round()}', uvLabel, Icons.wb_sunny_outlined)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildDetailCard('Visibility', '${weather.visibility.round()} km', '', Icons.remove_red_eye_outlined)),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildDetailCard('Pressure', '${weather.pressure} hPa', '', Icons.speed)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildDetailCard('Sunrise', weather.sunrise, '', Icons.wb_twilight)),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildDetailCard('Sunset', weather.sunset, '', Icons.nights_stay_outlined)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildDetailCard('Dew Point', '${weather.dewPoint.round()}°', '', Icons.water_drop_outlined)),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Air Quality Index', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${weather.airQualityIndex}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Text(airQualityLabel, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      airQualityLabel == 'Good'
                          ? 'Air quality is satisfactory and poses little or no risk.'
                          : 'Air quality may affect sensitive groups; consider limiting outdoor time.',
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              Icon(icon, color: Colors.blueAccent, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }
}