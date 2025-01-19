import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherProvider with ChangeNotifier {
  Weather? _currentWeather;

  Weather? get currentWeather => _currentWeather;

  Future<void> fetchWeather(String cityName) async {
    final apiKey = '4205fb03d57029b9dc2d01788945f172';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parsowanie danych API
        final data = json.decode(response.body);
        _currentWeather = Weather.fromJson(data);
        notifyListeners();
      } else if (response.statusCode == 404) {
        throw Exception('Nie znaleziono miasta: $cityName');
      } else if (response.statusCode == 401) {
        throw Exception('Niepoprawny klucz API');
      } else {
        throw Exception('Nie udało się pobrać danych pogodowych (status: ${response.statusCode})');
      }
    } catch (error) {
      print('Error fetching weather: $error'); // Debugowanie błędu
      rethrow; // Ponowne zgłoszenie błędu do obsługi w FutureBuilder
    }
  }
}
