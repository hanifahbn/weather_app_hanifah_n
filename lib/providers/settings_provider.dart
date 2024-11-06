import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'weather_provider.dart';
import 'dart:convert';
import '../constants/colors.dart';

class Settings {
  String measurementUnit;
  String currentCity;
  bool isDarkMode;

  Settings({
    this.measurementUnit = 'Celsius',
    this.currentCity = '',
    this.isDarkMode = false,
  });
}

class SettingsProvider with ChangeNotifier {
  Settings _settings = Settings();

  Settings get settings => _settings;

  SettingsProvider() {
    _initializeSettings();
  }

  Future<void> loadSettings() async {
    await _initializeSettings();
    notifyListeners();
  }

  Future<void> _initializeSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _settings.measurementUnit = prefs.getString('measurementUnit') ?? 'Celsius';
    _settings.currentCity = prefs.getString('currentCity') ?? '';
    _settings.isDarkMode = prefs.getBool('isDarkMode') ?? false;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        print('Location permissions are denied.');
        return;
      }

      if (_settings.currentCity.isEmpty) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        String city = await _getCityFromPosition(position);
        _settings.currentCity = city;
        notifyListeners();
      }

      notifyListeners();

    } catch (e) {
      print('Error initializing settings: $e');
    }
  }


  Future<void> _fetchLocationAndSetCity() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        print('Location permissions are denied.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      String city = await _getCityFromPosition(position);
      _settings.currentCity = city;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('currentCity', city);

      notifyListeners();
    } catch (e) {
      print('Error initializing settings: $e');
    }
  }

  Future<String> _getCityFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      return placemarks.first.locality ?? 'Unknown City';
    } catch (e) {
      print('Error getting city from position: $e');
      return 'Unknown City';
    }
  }

  void changeMeasurementUnit(String unit, WeatherProvider weatherProvider, BuildContext context) {
    _settings.measurementUnit = unit;
    notifyListeners();
    weatherProvider.loadWeatherData(context);
  }

  void toggleDarkMode() {
    _settings.isDarkMode = !_settings.isDarkMode;
    AppColors.isDarkMode = _settings.isDarkMode;
    saveSettings();
    notifyListeners();
  }

  void changeCity(String newCity, WeatherProvider weatherProvider, BuildContext context) async {
    bool cityExists = await _cityExistsInJson(newCity);

    if (cityExists) {
      _settings.currentCity = newCity;
      notifyListeners();
      weatherProvider.loadWeatherData(context);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('City Not Found'),
          content: Text('The city "$newCity" is not in the list. Please try another city.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<bool> _cityExistsInJson(String city) async {
    try {
      final String response = await rootBundle.loadString('assets/kota.json');
      final Map<String, dynamic> jsonData = json.decode(response);
      final List<dynamic> cityList = jsonData["kota"] ?? [];

      return cityList.contains(city);
    } catch (e) {
      print('Error checking city existence in JSON: $e');
      return false;
    }
  }

  Future<List<String>> getCitySuggestions(String query) async {
    List<String> suggestions = [];
    try {
      final String response = await rootBundle.loadString('assets/kota.json');
      final Map<String, dynamic> jsonData = json.decode(response);

      final List<dynamic> cityList = jsonData['kota'];

      suggestions = cityList.where((city) {
        return city.toLowerCase().contains(query.toLowerCase());
      }).map((city) => city.toString()).toList();

    } catch (e) {
      print('Error fetching city suggestions from JSON: $e');
    }
    return suggestions;
  }

  void saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('measurementUnit', _settings.measurementUnit);
    prefs.setString('currentCity', _settings.currentCity);
    prefs.setBool('isDarkMode', _settings.isDarkMode);
    notifyListeners();
  }
}
