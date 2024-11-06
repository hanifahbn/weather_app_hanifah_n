import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app_hanifah_n/models/weather.dart';
import 'package:weather_app_hanifah_n/providers/weather_provider.dart';
import '../constants/colors.dart';
import '../providers/settings_provider.dart';

class ForecastPage extends StatefulWidget {
  const ForecastPage({Key? key}) : super(key: key);

  @override
  _ForecastPageState createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> {
  late PageController _pageController;
  late ValueNotifier<int> _currentPageNotifier;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
    _currentPageNotifier = ValueNotifier(0);

    Future.microtask(() {
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      weatherProvider.loadDailyForecast(context);
    });

    _pageController.addListener(() {
      _currentPageNotifier.value = _pageController.page?.round() ?? 0;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final dailyForecast = weatherProvider.dailyForecast;
    final settingsProvider = Provider.of<SettingsProvider>(context);
    AppColors.isDarkMode = settingsProvider.settings.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Forecast'),
        backgroundColor: AppColors.pure,
        foregroundColor: AppColors.isDarkMode ? Colors.white : Colors.black,
      ),
      backgroundColor: AppColors.pure,
      body: weatherProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dailyForecast != null && dailyForecast.isNotEmpty
          ? Column(
        children: [
          ValueListenableBuilder<int>(
            valueListenable: _currentPageNotifier,
            builder: (context, currentIndex, child) {
              final forecast = dailyForecast[currentIndex];
              return Column(
                children: [
                  const SizedBox(height: 40),
                  Text(
                    forecast.day,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.denim,
                    ),
                  ),
                  Text(
                    forecast.date,
                    style: TextStyle(
                      fontSize: 24,
                      color: AppColors.denim,
                    ),
                  ),
                ],
              );
            },
          ),
          Expanded(
            child: PageView.builder(
              itemCount: dailyForecast.length,
              controller: _pageController,
              itemBuilder: (context, index) {
                final forecast = dailyForecast[index];
                return _buildForecastCard(context, forecast);
              },
            ),
          ),
        ],
      )
          : const Center(child: Text('No forecast data available')),
    );
  }

  Widget _buildForecastCard(BuildContext context, Weather forecast) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 40),
      child: Card(
          elevation: 20,
          color: AppColors.pure,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColors.denim, width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '°${Provider.of<SettingsProvider>(context, listen: false).settings.measurementUnit}',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.denim.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      Provider.of<WeatherProvider>(context, listen: false)
                          .getFormattedTemperature(
                              forecast.temperature, context),
                      style: TextStyle(
                        fontSize: 100,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -10.0,
                        color: AppColors.denim,
                        height: 1,
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.sunny, color: AppColors.denim.withOpacity(0.8)),
                    const SizedBox(width: 4),
                    Text(
                      forecast.condition,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.denim.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(
                  color: AppColors.denim.withOpacity(0.3),
                  thickness: 1,
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 10.0),
                  child: Container(
                    width: double.maxFinite,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.waves_sharp, color: AppColors.denim, size: 40),
                                const SizedBox(height: 5),
                                Text(
                                  '${forecast.windSpeed} kph',
                                  style: TextStyle(color: AppColors.denim, fontSize: 20),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Wind Speed',
                                  style: TextStyle(color: AppColors.denim, fontSize: 15),
                                ),
                              ],
                            ),

                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.umbrella_outlined, color: AppColors.denim, size: 40),
                                const SizedBox(height: 5),
                                Text(
                                  '${forecast.precipitation} mm',
                                  style: TextStyle(color: AppColors.denim, fontSize: 20),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Precipitation',
                                  style: TextStyle(color: AppColors.denim, fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.water_drop_outlined, color: AppColors.denim, size: 40),
                                const SizedBox(height: 5),
                                Text(
                                  '${forecast.humidity}%',
                                  style: TextStyle(color: AppColors.denim, fontSize: 20),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Humidity',
                                  style: TextStyle(color: AppColors.denim, fontSize: 15),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.remove_red_eye_outlined, color: AppColors.denim, size: 40),
                                const SizedBox(height: 5),
                                Text(
                                  '${forecast.visibility} km',
                                  style: TextStyle(color: AppColors.denim, fontSize: 20),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Visibility',
                                  style: TextStyle(color: AppColors.denim, fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
