import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weatherapp/resources/global.dart';

final weatherProvider = NotifierProvider<WeatherProvider, String>(
  WeatherProvider.new,
);

class WeatherProvider extends Notifier<String> {
  @override
  String build() => "";

  /// Change State
  changeWeatherType(String val) {
    state = val;
  }

  /// Get Image
  String getImage(String type, bool isNight) {
    switch (type.toLowerCase()) {
      case 'thunderstorm':
        return isNight ? AppImages.nightStorm : AppImages.dayStorm;
      case 'drizzle':
      case 'rain':
        return isNight ? AppImages.nightRain : AppImages.dayRain;
      case 'snow':
        return isNight ? AppImages.nightSnow : AppImages.daySnow;
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'sand':
      case 'ash':
      case 'squall':
      case 'tornado':
        return isNight ? AppImages.nightWind : AppImages.dayWind;
      case 'clear':
        return isNight ? AppImages.nightMoon : AppImages.daySun;
      case 'clouds':
        return isNight ? AppImages.nightClouds : AppImages.dayClouds;
      default:
        return isNight ? AppImages.nightMoon : AppImages.daySun;
    }
  }

  /// Detect Shadow Color
  List<BoxShadow> boxShadow(BuildContext context, bool isNight) {
    if (state.isEmpty) {
      return [];
    }

    switch (isNight) {
      case true:
        return [
          BoxShadow(
            blurRadius: MediaQuery.of(context).size.width / 2,
            color: Colors.white.withOpacity(0.3),
            spreadRadius: -50,
            blurStyle: BlurStyle.inner,
          ),
        ];
      case false:
        return [
          BoxShadow(
            blurRadius: MediaQuery.of(context).size.width / 2,
            color: Colors.yellowAccent.withOpacity(0.3),
            spreadRadius: -50,
            blurStyle: BlurStyle.inner,
          ),
        ];
      default:
        return [];
    }
  }
}
