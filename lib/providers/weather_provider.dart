import 'package:flutter/material.dart';
import 'package:weather_app_hanifah_n/models/weather.dart';
import '../providers/settings_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

class WeatherProvider with ChangeNotifier {
  Weather? _currentWeather;
  List<Weather>? _dailyForecast;
  bool isLoading = false;

  Weather? get currentWeather => _currentWeather;
  List<Weather>? get dailyForecast => _dailyForecast;

  Future<void> loadWeatherData(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    String city = settingsProvider.settings.currentCity;

    try {
      _currentWeather = await fetchWeatherByCity(city);
    } catch (e) {
      print("Error fetching weather data: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDailyForecast(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    String city = settingsProvider.settings.currentCity;

    try {
      _dailyForecast = await fetchDailyForecastByCity(city);
      notifyListeners();
    } catch (e) {
      print("Error fetching daily forecast: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Weather> fetchWeatherByCity(String city) async {
    final apiKey = 'ca061f21cfe648f4baf154028240411';
    final url = 'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$city&days=1';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Weather.fromJson(data);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<List<Weather>> fetchDailyForecastByCity(String city) async {
    final apiKey = 'ca061f21cfe648f4baf154028240411';
    final url = 'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$city&days=10';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Weather> dailyForecast = (data['forecast']['forecastday'] as List)
          .map((forecast) => Weather.fromJsonForDailyForecast(forecast))
          .toList();
      return dailyForecast;
    } else {
      throw Exception('Failed to load daily forecast data');
    }
  }

  String getFormattedTemperature(int temperature, BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    bool isCelsius = settingsProvider.settings.measurementUnit == 'Celsius';

    String formattedTemperature = isCelsius
        ? '$temperature°'
        : '${((temperature * 9 / 5) + 32).toInt()}°';

    return formattedTemperature;
  }

}
