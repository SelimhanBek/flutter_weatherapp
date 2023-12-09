/// Common Functions
class AppGlobal {
  /// Detect Night or Day Light
  static bool isNight(int hour) {
    switch (hour) {
      case > 17:
        return true;
      case < 6:
        return true;
      default:
        return false;
    }
  }

  /// Kelvin to Cantigrate
  static double kelvinToCelsius(double kelvin) {
    return (kelvin - 273.15).ceilToDouble();
  }

  /// Parse Hourly
  static Future<List<Map<String, dynamic>>> parseHourly(
      Map<String, dynamic> report) async {
    try {
      List<Map<String, dynamic>> list = [];
      int curDay = DateTime.now().day;

      for (var i = 0; i < report['hourly'].length; i++) {
        var date = DateTime.fromMillisecondsSinceEpoch(
          report['hourly'][i]['dt'] * 1000,
          isUtc: false,
        );

        if (date.day == curDay) {
          list.add({
            "type": report['hourly'][i]['weather'][0]['main'],
            "hour": date.hour.toString().padLeft(2, '0'),
            "min": date.minute.toString().padLeft(2, '0'),
            "temp": AppGlobal.kelvinToCelsius(report['hourly'][i]['temp'])
          });
        }
      }

      return list;
    } catch (e) {
      return [];
    }
  }

  /// Months
  static final List<String> _months = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık'
  ];

  /// Date
  static String getDate(DateTime dateTime) {
    String month = _months[dateTime.month - 1];
    String day = dateTime.day.toString();
    String year = dateTime.year.toString();

    return '$month $day, $year';
  }
}

/// Image Extensions
class AppImages {
  static const String _weatherImagesPath = "assets/images";

  static const String daySun = "$_weatherImagesPath/Day Sun.png";
  static const String dayClouds = "$_weatherImagesPath/Day Clouds.png";
  static const String dayRain = "$_weatherImagesPath/Day Rain.png";
  static const String daySnow = "$_weatherImagesPath/Day Snow.png";
  static const String dayStorm = "$_weatherImagesPath/Day Storm.png";
  static const String dayWind = "$_weatherImagesPath/Day Wind.png";
  static const String dayBlur = "$_weatherImagesPath/day_blured.svg";

  static const String nightMoon = "$_weatherImagesPath/Night Moon.png";
  static const String nightClouds = "$_weatherImagesPath/Night Clouds.png";
  static const String nightRain = "$_weatherImagesPath/Night Rain.png";
  static const String nightSnow = "$_weatherImagesPath/Night Snow.png";
  static const String nightStorm = "$_weatherImagesPath/Night Storm.png";
  static const String nightWind = "$_weatherImagesPath/Night Wind.png";
  static const String nightBlur = "$_weatherImagesPath/night_blured.svg";
}
