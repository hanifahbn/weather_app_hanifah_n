import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import 'forecast_page.dart';
import 'settings_page.dart';
import '/providers/settings_provider.dart';
import '../constants/colors.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      await settingsProvider.loadSettings();

      if (settingsProvider.settings.currentCity.isNotEmpty) {
        Provider.of<WeatherProvider>(context, listen: false)
            .loadWeatherData(context);
      } else {
        print("City not set in settings");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final currentWeather = weatherProvider.currentWeather;

    final settingsProvider = Provider.of<SettingsProvider>(context);
    AppColors.isDarkMode = settingsProvider.settings.isDarkMode;

    return Scaffold(
        backgroundColor: AppColors.pure,
        body: SingleChildScrollView(
          child: weatherProvider.isLoading
              ? const Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : currentWeather == null
                  ? const Center(child: Text('Weather data is not available.'))
                  : Padding(
                      padding: const EdgeInsets.only(
                          left: 0.0, right: 0.0, top: 80.0, bottom: 50.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'today',
                                      style: TextStyle(
                                        fontSize: 55,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.denim,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.settings),
                                      iconSize: 40,
                                      color: AppColors.denim,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SettingsPage()),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        color: AppColors.denim),
                                    const SizedBox(width: 4),
                                    Text(
                                      currentWeather.city,
                                      style: TextStyle(
                                          fontSize: 24, color: AppColors.denim),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    currentWeather.date ?? "01 Januari 1999",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: AppColors.denim,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '°${settingsProvider.settings.measurementUnit}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: AppColors.denim
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          weatherProvider
                                              .getFormattedTemperature(
                                                  currentWeather.temperature,
                                                  context),
                                          style: TextStyle(
                                            fontSize: 160,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: -15.0,
                                            color: AppColors.denim,
                                            height: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(Icons.sunny,
                                            color: AppColors.denim
                                                .withOpacity(0.5)),
                                        const SizedBox(width: 4),
                                        Text(
                                          currentWeather.condition,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: AppColors.denim
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (currentWeather.hourlyForecast.isNotEmpty)
                            Divider(
                              color: AppColors.denim.withOpacity(0.1),
                              thickness: 1,
                              height: 20,
                            ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: currentWeather.hourlyForecast.length,
                              itemBuilder: (context, index) {
                                final hourData =
                                    currentWeather.hourlyForecast[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        hourData['time'],
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: AppColors.isDarkMode
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${weatherProvider.getFormattedTemperature(hourData['temperature'], context)}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.isDarkMode
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          Divider(
                            color: AppColors.denim.withOpacity(0.1),
                            thickness: 1,
                            height: 10,
                          ),
                          Container(
                            width: double.maxFinite,
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 5.0, bottom: 5),
                            child: Card(
                              color: AppColors.denim,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: AppColors.denim, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Icon(Icons.waves_sharp,
                                            color: AppColors.pure, size: 50),
                                        const SizedBox(height: 5),
                                        Text(
                                          '${currentWeather.windSpeed} kph',
                                          style: TextStyle(
                                              color: AppColors.pure,
                                              fontSize: 20),
                                        ),
                                        const SizedBox(height: 2),
                                        Text('Wind Speed',
                                            style: TextStyle(
                                                color: AppColors.pure,
                                                fontSize: 10)),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Icon(Icons.water_drop_outlined,
                                            color: AppColors.pure, size: 50),
                                        const SizedBox(height: 5),
                                        Text(
                                          '${currentWeather.humidity}%',
                                          style: TextStyle(
                                              color: AppColors.pure,
                                              fontSize: 20),
                                        ),
                                        const SizedBox(height: 2),
                                        Text('Humidity',
                                            style: TextStyle(
                                                color: AppColors.pure,
                                                fontSize: 10)),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Icon(Icons.umbrella_outlined,
                                            color: AppColors.pure, size: 50),
                                        SizedBox(height: 5),
                                        Text(
                                          currentWeather.precipitation
                                              .toString(),
                                          style: TextStyle(
                                              color: AppColors.pure,
                                              fontSize: 20),
                                        ),
                                        const SizedBox(height: 2),
                                        Text('Precipitation',
                                            style: TextStyle(
                                                color: AppColors.pure,
                                                fontSize: 10)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // const Spacer(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ElevatedButton(
                              onPressed: () async {
                                await weatherProvider
                                    .loadDailyForecast(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ForecastPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text('See Forecasts'),
                            ),
                          )
                        ],
                      ),
                    ),
        ));
  }
}
