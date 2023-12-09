import 'package:dio/dio.dart';

class WeatherMethods {
  /* Base URL */
  static String get baseURL => "https://api.openweathermap.org/data/3.0";

  /* API Key */
  static String get apiKey => "d3941861af6634a152ac6fc020cd151c";

  /* Excludes */
  static String get excludeCurrent => "current";
  static String get excludeMinutely => "minutely";
  static String get excludeHourly => "hourly";
  static String get excludeDaily => "daily";

  /* Client Dio(http) Session */
  static Dio dio() {
    BaseOptions defaultOptions = BaseOptions(
      baseUrl: Uri.encodeFull(baseURL),
      contentType: "application/json",
      followRedirects: false,
      validateStatus: (status) {
        return status! < 500;
      },
      headers: {},
      extra: {
        "withCredentials": false,
      },
    );

    final Dio myDio = Dio(defaultOptions);

    return myDio;
  }

  /* One call */
  Future<Map<String, dynamic>> getWeather({
    required double latitude,
    required double longitude,
    String exclude = "",
  }) async {
    var url = Uri.encodeFull(
      exclude.isEmpty
          ? "/onecall?lat=$latitude&lon=$longitude&appid=$apiKey"
          : "/onecall?lat=$latitude&lon=$longitude&exclude=$exclude&appid=$apiKey",
    );

    try {
      var res = await dio().get(url);

      if (res.statusCode == 200) {
        return res.data;
      } else {
        return {
          "status": false,
          "msg": res.statusCode,
        };
      }
    } catch (e) {
      return {
        "status": false,
        "msg": e.toString(),
      };
    }
  }
}
