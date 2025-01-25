import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../models/daily_forecast.dart';
import 'package:latlong2/latlong.dart';

class WeatherProvider with ChangeNotifier {
  Weather? _currentWeather;
  List<DailyForecast> _forecast = [];
  final Set<String> _favoriteCities = {};
  final Map<String, LatLng> _cityCoordinatesCache = {}; // Cache for coordinates

  Weather? get currentWeather => _currentWeather;
  List<DailyForecast> get forecast => _forecast;
  Set<String> get favoriteCities => _favoriteCities;

  Future<void> fetchWeather(String cityName) async {
    final apiKey = '4205fb03d57029b9dc2d01788945f172';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric&lang=pl';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentWeather = Weather.fromJson(data);

        // Update coordinates cache
        final lat = data['coord']['lat'];
        final lon = data['coord']['lon'];
        _cityCoordinatesCache[cityName] = LatLng(lat, lon);

        notifyListeners();
      } else {
        throw Exception('Failed to fetch weather data: ${response.statusCode}');
      }
    } catch (error) {
      developer.log('Error fetching weather: $error');
      rethrow;
    }
  }

  Future<void> fetchForecast(String cityName) async {
    final apiKey = '4205fb03d57029b9dc2d01788945f172';
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$apiKey&units=metric&lang=pl';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> forecastList = data['list'];

        _forecast = forecastList
            .map((item) => DailyForecast.fromJson(item))
            .toList();
        notifyListeners();
      } else {
        throw Exception('Failed to fetch forecast data: ${response.statusCode}');
      }
    } catch (error) {
      developer.log('Error fetching forecast: $error');
      rethrow;
    }
  }

  void toggleFavoriteCity(String cityName) {
    if (_favoriteCities.contains(cityName)) {
      _favoriteCities.remove(cityName);
    } else {
      _favoriteCities.add(cityName);
    }
    notifyListeners();
  }

  bool isFavorite(String cityName) => _favoriteCities.contains(cityName);

  LatLng getCoordinatesForCity(String cityName) {
    if (_cityCoordinatesCache.containsKey(cityName)) {
      return _cityCoordinatesCache[cityName]!;
    } else {
      throw Exception('Coordinates for city $cityName not found.');
    }
  }

  Map<String, List<DailyForecast>> groupForecastByDate(
      List<DailyForecast> forecast) {
    Map<String, List<DailyForecast>> groupedData = {};

    for (var item in forecast) {
      final date = item.date.split(' ')[0];
      if (groupedData[date] == null) {
        groupedData[date] = [];
      }
      groupedData[date]!.add(item);
    }

    return groupedData;
  }

  List<Map<String, dynamic>> getDailySummary(
      Map<String, List<DailyForecast>> groupedForecast) {
    List<Map<String, dynamic>> dailySummary = [];

    groupedForecast.forEach((date, forecasts) {
      double totalTemp = 0;
      Map<String, int> conditionCount = {};

      for (var forecast in forecasts) {
        totalTemp += forecast.temperature;

        conditionCount[forecast.condition] =
            (conditionCount[forecast.condition] ?? 0) + 1;
      }

      String dominantCondition = conditionCount.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      dailySummary.add({
        'date': date,
        'averageTemp': (totalTemp / forecasts.length).toStringAsFixed(0),
        'condition': dominantCondition,
        'icon': forecasts.first.icon,
      });
    });

    return dailySummary;
  }
}
