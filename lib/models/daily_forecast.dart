class DailyForecast {
  final String date;
  final String condition;
  final double temperature;
  final String icon;

  DailyForecast({
    required this.date,
    required this.condition,
    required this.temperature,
    required this.icon,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json['dt_txt'],
      condition: json['weather'][0]['description'],
      temperature: (json['main']['temp'] as num).toDouble(),
      icon: json['weather'][0]['icon'],
    );
  }
}
