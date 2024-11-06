import 'dart:io';

import 'package:flutter/material.dart';
import '/pages/home_page.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../providers/settings_provider.dart';
import '/constants/colors.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App - by Hanifah N.',
      theme: ThemeData(
        fontFamily: Platform.isAndroid ? 'SF' : null,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.denim.withOpacity(0.3),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Weather App'),
    );
  }
}
