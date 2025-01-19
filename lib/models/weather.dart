class Weather {
  final String condition;
  final double temperature;
  final double windSpeed;
  final int windDirection;
  final int cloudiness;
  final String icon; // Dodane pole

  Weather({
    required this.condition,
    required this.temperature,
    required this.windSpeed,
    required this.windDirection,
    required this.cloudiness,
    required this.icon, // Dodane pole
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    try {
      return Weather(
        condition: json['weather'][0]['description'] as String,
        temperature: (json['main']['temp'] as num).toDouble(),
        windSpeed: (json['wind']['speed'] as num).toDouble(),
        windDirection: json['wind']['deg'] as int,
        cloudiness: json['clouds']['all'] as int,
        icon: json['weather'][0]['icon'] as String, // Pobieramy kod ikony z API
      );
    } catch (e) {
      throw Exception('Błąd parsowania danych pogodowych: $e');
    }
  }
}
