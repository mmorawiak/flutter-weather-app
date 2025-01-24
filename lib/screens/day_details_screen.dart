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

  String translateCondition(String condition) {
    final Map<String, String> translations = {
      'clear sky': 'Bezchmurnie',
      'few clouds': 'Małe zachmurzenie',
      'scattered clouds': 'Rozproszone chmury',
      'broken clouds': 'Zachmurzenie umiarkowane',
      'shower rain': 'Przelotny deszcz',
      'rain': 'Deszcz',
      'thunderstorm': 'Burza',
      'snow': 'Śnieg',
      'mist': 'Mgła',
      'overcast clouds': 'Zachmurzenie duże',
    };

    return translations[condition.toLowerCase()] ?? condition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Szczegóły prognozy: $date'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: details.length,
          itemBuilder: (ctx, index) {
            final forecast = details[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Image.network(
                  'http://openweathermap.org/img/wn/${forecast.icon}@2x.png',
                  width: 50,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.cloud_off,
                      size: 50,
                      color: Colors.grey,
                    );
                  },
                ),
                title: Text(
                  '${forecast.date.split(' ')[1]}:00',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                subtitle: Text(
                  translateCondition(forecast.condition),
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),
                trailing: Text(
                  '${forecast.temperature.toStringAsFixed(0)}°C',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
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
