import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../models/daily_forecast.dart';

class WeatherProvider with ChangeNotifier {
  Weather? _currentWeather;
  List<DailyForecast> _forecast = [];

  Weather? get currentWeather => _currentWeather;
  List<DailyForecast> get forecast => _forecast;

  Future<void> fetchWeather(String cityName) async {
    final apiKey = '4205fb03d57029b9dc2d01788945f172';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric&lang=pl';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentWeather = Weather.fromJson(data);
        notifyListeners();
      } else if (response.statusCode == 404) {
        throw Exception('Nie znaleziono miasta: $cityName');
      } else if (response.statusCode == 401) {
        throw Exception('Niepoprawny klucz API');
      } else {
        throw Exception(
            'Nie udało się pobrać danych pogodowych (status: ${response.statusCode})');
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
      } else if (response.statusCode == 404) {
        throw Exception('Nie znaleziono miasta: $cityName');
      } else if (response.statusCode == 401) {
        throw Exception('Niepoprawny klucz API');
      } else {
        throw Exception(
            'Nie udało się pobrać danych prognozy (status: ${response.statusCode})');
      }
    } catch (error) {
      developer.log('Error fetching forecast: $error');
      rethrow;
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
