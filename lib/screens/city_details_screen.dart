import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import 'city_map_screen.dart';

class CityDetailsScreen extends StatefulWidget {
  final String cityName;

  const CityDetailsScreen({super.key, required this.cityName});

  @override
  State<CityDetailsScreen> createState() => _CityDetailsScreenState();
}

class _CityDetailsScreenState extends State<CityDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    try {
      await Future.wait([
        weatherProvider.fetchWeather(widget.cityName),
        weatherProvider.fetchForecast(widget.cityName),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nie udało się pobrać danych.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final weather = weatherProvider.currentWeather;
    final forecast = weatherProvider.forecast;

    if (weather == null || forecast.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.cityName),
          backgroundColor: Colors.blueAccent,
          actions: [
            Selector<WeatherProvider, bool>(
              selector: (_, provider) => provider.isFavorite(widget.cityName),
              builder: (ctx, isFavorite, _) => IconButton(
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.yellow : Colors.white,
                ),
                onPressed: () {
                  weatherProvider.toggleFavoriteCity(widget.cityName);
                },
              ),
            ),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final groupedForecast = weatherProvider.groupForecastByDate(forecast);
    final dailySummary = weatherProvider.getDailySummary(groupedForecast);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cityName),
        backgroundColor: Colors.blueAccent,
        actions: [
          Selector<WeatherProvider, bool>(
            selector: (_, provider) => provider.isFavorite(widget.cityName),
            builder: (ctx, isFavorite, _) => IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? Colors.yellow : Colors.white,
              ),
              onPressed: () {
                weatherProvider.toggleFavoriteCity(widget.cityName);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const CityMapScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
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
                          builder: (ctx) => Scaffold(
                            appBar: AppBar(
                              title: Text(daySummary['date']),
                            ),
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
                          daySummary['date'],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(daySummary['condition']),
                        trailing: Text(
                          '${daySummary['averageTemp']}°C',
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
      ),
    );
  }
}
