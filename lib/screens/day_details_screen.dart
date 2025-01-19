import 'package:flutter/material.dart';
import '../models/daily_forecast.dart';

class DayDetailsScreen extends StatelessWidget {
  final String date;
  final List<DailyForecast> details;

  const DayDetailsScreen({
    super.key,
    required this.date,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Szczegóły prognozy: $date'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: details.length,
          itemBuilder: (ctx, index) {
            final forecast = details[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Image.network(
                  'http://openweathermap.org/img/wn/${forecast.icon}@2x.png',
                  width: 50,
                  height: 50,
                ),
                title: Text(
                  forecast.date.split(' ')[1], // Wyświetla godzinę
                  style: const TextStyle(fontSize: 18),
                ),
                subtitle: Text(forecast.condition), // Opis warunków pogodowych
                trailing: Text(
                  '${forecast.temperature.toStringAsFixed(0)}°C', // Temperatura zaokrąglona do całkowitej
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
