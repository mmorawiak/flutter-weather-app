class Weather {
  final String condition;
  final double temperature;
  final double windSpeed;
  final int windDirection;
  final int cloudiness;

  Weather({
    required this.condition,
    required this.temperature,
    required this.windSpeed,
    required this.windDirection,
    required this.cloudiness,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    try {
      return Weather(
        condition: json['weather'][0]['description'] as String,
        temperature: (json['main']['temp'] as num).toDouble(),
        windSpeed: (json['wind']['speed'] as num).toDouble(),
        windDirection: json['wind']['deg'] as int,
        cloudiness: json['clouds']['all'] as int,
      );
    } catch (e) {
      throw Exception('Błąd parsowania danych pogodowych: $e');
    }
  }
}
