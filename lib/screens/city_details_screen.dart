import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import 'day_details_screen.dart';

class CityDetailsScreen extends StatelessWidget {
  final String cityName;

  const CityDetailsScreen({super.key, required this.cityName});

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(cityName),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder(
        future: Future.wait([
          weatherProvider.fetchWeather(cityName),
          weatherProvider.fetchForecast(cityName),
        ]),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Nie udało się pobrać danych.'));
          }

          final weather = weatherProvider.currentWeather!;
          final forecast = weatherProvider.forecast;

          final groupedForecast = weatherProvider.groupForecastByDate(forecast);
          final dailySummary = weatherProvider.getDailySummary(groupedForecast);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Image.network(
                              'http://openweathermap.org/img/wn/${weather.icon}@2x.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return const CircularProgressIndicator();
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.cloud_off,
                                  size: 100,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Temperatura:',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${weather.temperature.toStringAsFixed(0)}°C',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
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
                  const SizedBox(height: 20),

                  const Text(
                    'Prognoza na najbliższe dni:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dailySummary.length,
                    itemBuilder: (ctx, index) {
                      final daySummary = dailySummary[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => DayDetailsScreen(
                                date: daySummary['date'],
                                details: groupedForecast[daySummary['date']]!,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: Image.network(
                              'http://openweathermap.org/img/wn/${daySummary['icon']}@2x.png',
                              width: 50,
                              height: 50,
                            ),
                            title: Text(
                              daySummary['date'], // Data
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(daySummary['condition']), // Warunki
                            trailing: Text(
                              '${daySummary['averageTemp']}°C', // Średnia temperatura
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
