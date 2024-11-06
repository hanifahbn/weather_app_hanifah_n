import 'package:intl/intl.dart';

class Weather {
  final int temperature;
  final int humidity;
  final double windSpeed;
  final String condition;
  final String city;
  final List<Map<String, dynamic>> hourlyForecast;
  final String day;
  final String date;
  final double precipitation;
  final double visibility;

  Weather({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.city,
    required this.hourlyForecast,
    required this.day,
    required this.date,
    required this.precipitation,
    required this.visibility,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'] ?? {};
    final location = json['location'] ?? {};
    final hourly = (json['forecast']?['forecastday']?[0]?['hour'] ?? []) as List;

    String rawDate = json['forecast']?['forecastday']?[0]?['date'] ?? DateTime.now().toString();
    DateTime parsedDate = DateTime.parse(rawDate);

    return Weather(
      temperature: (current['temp_c'] ?? 0.0).toInt(),
      humidity: (current['humidity'] ?? 0) as int,
      windSpeed: (current['wind_kph'] ?? 0.0).toDouble(),
      condition: (current['condition']?['text'] ?? 'Unknown').toString(),
      city: (location['name'] ?? 'Unknown').toString(),
      hourlyForecast: hourly.map((data) {
        DateTime hourTime = DateTime.parse(data['time']);
        String formattedTime = DateFormat('h a').format(hourTime);
        return {
          'time': formattedTime.toLowerCase(),
          'temperature': (data['temp_c'] ?? 0.0).toInt(),
        };
      }).toList(),
      day: DateFormat('EEEE').format(parsedDate),
      date: DateFormat('d MMMM y').format(parsedDate),
      precipitation: (current['precip_mm'] ?? 0.0).toDouble(),
      visibility: 0.0,
    );
  }


  factory Weather.fromJsonForDailyForecast(Map<String, dynamic> json) {
    final day = json['day'] ?? {};

    String rawDate = json['forecast']?['forecastday']?[0]?['date'] ?? DateTime.now().toString();
    DateTime parsedDate = DateTime.parse(rawDate);

    return Weather(
      temperature: (day['avgtemp_c'] ?? 0.0).toInt(),
      humidity: (day['avghumidity'] ?? 0).toInt(),
      windSpeed: (day['maxwind_kph'] ?? 0.0).toDouble(),
      condition: (day['condition']?['text'] ?? 'Unknown').toString(),
      city: '',
      hourlyForecast: [],
      day: DateFormat('EEEE').format(DateTime.parse(json['date'] ?? DateTime.now().toString())),
      date: DateFormat('d MMMM y').format(parsedDate),
      precipitation: (day['totalprecip_mm'] ?? 0.0).toDouble(),
      visibility: (day['avgvis_km'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'condition': condition,
      'city': city,
      'hourlyForecast': hourlyForecast.map((hour) => {
        'time': hour['time'],
        'temperature': hour['temperature'],
      }).toList(),
      'day': day,
      'date': date,
      'precipitation': precipitation,
      'visibility': visibility,
    };
  }

}
