import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class CityDetailsScreen extends StatelessWidget {
  final String cityName;

  const CityDetailsScreen({super.key, required this.cityName});

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(cityName),
      ),
      body: FutureBuilder(
        future: weatherProvider.fetchWeather(cityName),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Nie udało się pobrać danych.'));
          }
          final weather = weatherProvider.currentWeather!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FadeInImage.assetNetwork(
                      placeholder: 'assets/loading.gif',
                      image:
                      'http://openweathermap.org/img/wn/${weather.icon}@2x.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.cloud_off,
                          size: 100,
                          color: Colors.grey,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Temperatura:',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${weather.temperature}°C',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Warunki:',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          weather.condition,
                          style: const TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Wiatr:',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          '${weather.windSpeed} km/h',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Zachmurzenie:',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          '${weather.cloudiness}%',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
