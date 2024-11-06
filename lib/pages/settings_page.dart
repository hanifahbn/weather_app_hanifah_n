import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/weather_provider.dart';
import '../constants/colors.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _cityController;
  bool _isChangingCity = false;
  List<String> _citySuggestions = [];

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    AppColors.isDarkMode = settingsProvider.settings.isDarkMode;

    if (_isChangingCity) {
      bool discardChanges = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Unsaved Changes'),
              content:
                  const Text('Do you really want to discard your changes?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
              ],
            ),
          ) ??
          false;

      if (!discardChanges) {
        settingsProvider.saveSettings();
      }

      return discardChanges;
    }
    return true;
  }

  void _fetchCitySuggestions(String query) async {
    if (query.isNotEmpty) {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final suggestions = await settingsProvider.getCitySuggestions(query);
      setState(() {
        _citySuggestions = suggestions;
      });
    } else {
      setState(() {
        _citySuggestions.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final settings = settingsProvider.settings;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.pure,
        appBar: AppBar(
          foregroundColor: AppColors.isDarkMode ? Colors.white : Colors.black,
          backgroundColor: AppColors.pure,
          title: const Text('Settings'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Measurement Units',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.denim,
                ),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Celsius',
                    activeColor: AppColors.denim,
                    groupValue: settings.measurementUnit,
                    onChanged: (value) {
                      final weatherProvider =
                          Provider.of<WeatherProvider>(context, listen: false);
                      settingsProvider.changeMeasurementUnit(
                          value!, weatherProvider, context);
                    },
                  ),
                  Text('Celsius',
                      style: TextStyle(fontSize: 20, color: AppColors.denim)),
                  Radio<String>(
                    value: 'Fahrenheit',
                    groupValue: settings.measurementUnit,
                    onChanged: (value) {
                      final weatherProvider =
                          Provider.of<WeatherProvider>(context, listen: false);
                      settingsProvider.changeMeasurementUnit(
                          value!, weatherProvider, context);
                    },
                  ),
                  Text('Fahrenheit',
                      style: TextStyle(fontSize: 20, color: AppColors.denim)),
                ],
              ),
              const SizedBox(height: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'City',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppColors.denim,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      settings.currentCity,
                      style: TextStyle(
                        fontSize: 20,
                        color: AppColors.denim,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isChangingCity)
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _cityController,
                            decoration: InputDecoration(
                              hintText: 'Enter city name',
                              hintStyle: TextStyle(
                                  color: AppColors.denim.withOpacity(0.5)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.denim),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.denim),
                              ),
                            ),
                            style: TextStyle(
                                color: AppColors.isDarkMode
                                    ? Colors.white
                                    : Colors.black),
                            onChanged: (value) {
                              _fetchCitySuggestions(value);
                            },
                          ),
                          if (_citySuggestions.isNotEmpty)
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppColors.pure,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  const BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListView.separated(
                                itemCount: _citySuggestions.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(),
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(_citySuggestions[index],
                                        style:
                                            TextStyle(color: AppColors.denim)),
                                    onTap: () {
                                      final weatherProvider =
                                          Provider.of<WeatherProvider>(context,
                                              listen: false);
                                      settingsProvider.changeCity(
                                          _citySuggestions[index],
                                          weatherProvider,
                                          context);
                                      _cityController.text =
                                          _citySuggestions[index];
                                      setState(() {
                                        _citySuggestions.clear();
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 20, top: _isChangingCity ? 20 : 0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_isChangingCity) {
                            final weatherProvider =
                                Provider.of<WeatherProvider>(context,
                                    listen: false);
                            final newCity = _cityController.text;
                            settingsProvider.changeCity(
                                newCity, weatherProvider, context);
                          }

                          setState(() {
                            _isChangingCity = !_isChangingCity;
                            if (!_isChangingCity) _cityController.clear();
                          });
                        },
                        child: Text(_isChangingCity ? 'Save' : 'Change City'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Dark Mode",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppColors.denim,
                    ),
                  ),
                  Transform.scale(
                    scale: 1.2,
                    child: Switch(
                      value: settings.isDarkMode,
                      onChanged: (value) {
                        settingsProvider.toggleDarkMode();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
