import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weatherapp/providers/location.dart';
import 'package:weatherapp/providers/weather.dart';
import 'package:weatherapp/resources/global.dart';
import 'package:weatherapp/resources/weather.dart';
import 'package:weatherapp/theme/palette.dart';
import 'package:weatherapp/theme/theme.dart';

class MobileScreenLayout extends ConsumerStatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  MobileScreenLayoutState createState() => MobileScreenLayoutState();
}

class MobileScreenLayoutState extends ConsumerState<MobileScreenLayout>
    with TickerProviderStateMixin {
  /* Animation */
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 10000),
    vsync: this,
  )..repeat();

  /* Local Variables */
  final int _time = 1500;
  late double imgSize = 200;
  late bool _isNight = AppGlobal.isNight(DateTime.now().hour);
  late Map<String, dynamic> _report;
  late List<Map<String, dynamic>> _hourly = [];

  /* Get Location */
  _getLocation() async =>
      await ref.read(locationProvider.notifier).updateLocation();

  /* Update Weather */
  _updateWeather(String val) =>
      ref.read(weatherProvider.notifier).changeWeatherType(val);

  /* Get Image Path */
  _getImage(String type, bool isNight) =>
      ref.read(weatherProvider.notifier).getImage(type, isNight);

  /* Set Image Size */
  _setImageSize(Size size) {
    if (mounted) {
      setState(() {
        imgSize = imgSize > size.width / 1.5
            ? size.width / 1.5 - 15
            : size.width / 1.5 + 15;
      });
    }
  }

  /* Image Animation */
  _imageAnimation(Size size) {
    Timer.periodic(
      Duration(milliseconds: _time),
      (timer) => _setImageSize(size),
    ).tick;
  }

  /* Update Response */
  _updateReport(Map<String, dynamic> res) {
    if (mounted) {
      _report = res;
    }
  }

  /* Change Is Night Status */
  _updateIsNight(bool val) {
    /* Change Theme */
    ref.read(themeProvider.notifier).changeAppTheme(
          mode: val ? ThemeMode.dark : ThemeMode.light,
        );

    /* Change Image */
    _updateWeather(
      _getImage(
        _report['current']['weather'][0]['main'],
        val,
      ),
    );

    /* Update State */
    setState(() {
      _isNight = val;
    });
  }

  /* Hourly */
  _parseHourly(Map<String, dynamic> res) async {
    List<Map<String, dynamic>> list = await AppGlobal.parseHourly(res);

    setState(() {
      _hourly = list;
    });
  }

  /* Get Api Call */
  _callApi() async {
    /* Update Location */
    //await _getLocation();

    /* Get Current Report */
    Map<String, dynamic> api = await WeatherMethods().getWeather(
      latitude: ref.read(locationProvider).latitude,
      longitude: ref.read(locationProvider).longitude,
    );

    /* Load Weather Details */
    await _parseHourly(api);
    _updateReport(api);
    if (mounted) {
      _setImageSize(MediaQuery.of(context).size);
      _imageAnimation(MediaQuery.of(context).size);
      _updateWeather(
        _getImage(
          api['current']['weather'][0]['main'],
          _isNight,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _callApi();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weather = ref.watch(weatherProvider);
    final loc = ref.watch(locationProvider);
    final size = MediaQuery.of(context).size;
    final Shader linearGradient = LinearGradient(
      colors: _isNight
          ? <Color>[AppPalette.cloud, AppPalette.thunderstorm]
          : <Color>[AppPalette.rain, AppPalette.wind],
    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

    /* Degree */
    Widget degree() {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            /* Degree */
            Text(
              "${AppGlobal.kelvinToCelsius(_report['current']['temp']).toStringAsFixed(1)}°",
              maxLines: 1,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 100,
                    fontWeight: FontWeight.w900,
                    foreground: Paint()..shader = linearGradient,
                  ),
            ),

            /* Type */
            Expanded(
              child: Text(
                '    ~ ${_report['current']['weather'][0]['main']}',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 18,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    /* Image */
    Widget image() {
      return AnimatedContainer(
        duration: Duration(milliseconds: _time),
        height: imgSize,
        width: imgSize,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(99)),
          boxShadow: ref.read(weatherProvider.notifier).boxShadow(
                context,
                _isNight,
              ),
        ),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  weather,
                ),
              ),
            ),
          ),
        ),
      );
    }

    /* Hourly Widget */
    Widget hourly(int index) {
      return Container(
        height: 90,
        width: 90,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          border: Border.all(
            width: 0.2,
            color: _isNight ? Colors.grey.shade300 : Colors.grey.shade800,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /* a little space */
              const SizedBox(height: 5),

              /* Image */
              SizedBox(
                width: 50,
                height: 50,
                child: Image.asset(
                  _getImage(
                    _hourly[index]['type'].toString().toLowerCase(),
                    AppGlobal.isNight(int.parse(_hourly[index]['hour'])),
                  ),
                ),
              ),

              /* a little space */
              const SizedBox(height: 7.5),

              /* Info */
              Row(
                children: [
                  /* a little space */
                  const SizedBox(width: 2.5),

                  /* Hour */
                  Expanded(
                    child: Text(
                      '${_hourly[index]['hour']}:${_hourly[index]['min']}',
                    ),
                  ),

                  /* Temp */
                  Text(
                    '${_hourly[index]['temp']}°',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  /* a little space */
                  const SizedBox(width: 2.5),
                ],
              ),

              /* a little space */
              const SizedBox(height: 5),
            ],
          ),
        ),
      );
    }

    /* BeforeLoad */
    Widget beforeLoad() {
      return Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            return Transform.rotate(
              angle: _controller.value * 5 * pi,
              child: child,
            );
          },
          child: RotationTransition(
            turns: const AlwaysStoppedAnimation(45 / 360),
            child: Container(
              margin: const EdgeInsets.all(0),
              width: size.width / 1.5,
              height: size.width / 1.5,
              child: Image.asset(
                _isNight ? AppImages.nightMoon : AppImages.daySun,
              ),
            ),
          ),
        ),
      );
    }

    /* Report */
    Widget report() {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            width: double.infinity,
            child: Text(
              AppGlobal.getDate(DateTime.now()),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 14,
                  ),
            ),
          ),

          /* a little space */
          const SizedBox(height: 20),

          /* Image */
          SizedBox(
            width: size.width / 1.4,
            height: size.width / 1.4,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                image(),
              ],
            ),
          ),

          /* Night Mode */
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            child: TextButton(
              onPressed: () => _updateIsNight(!_isNight),
              child: Row(
                children: [
                  /* Text */
                  Expanded(
                    child: Text(_isNight
                        ? "Gündüz Modu (Otomatik)"
                        : "Gece Modu (Otomatik)"),
                  ),

                  /* Switch */
                  Switch(
                    value: _isNight,
                    onChanged: (val) => _updateIsNight(val),
                  ),
                ],
              ),
            ),
          ),

          /* Degree */
          degree(),

          /* Wind Speed */
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            child: Row(
              children: [
                /* Header */
                Text(
                  'Rüzgar Hızı:',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                ),

                /* a little space */
                const SizedBox(width: 7.5),

                /* Value */
                Expanded(
                  child: Text(
                    _report['current']['wind_speed'].toString(),
                  ),
                ),
              ],
            ),
          ),

          /* a little space */
          const SizedBox(height: 30),

          /* Hourly */
          if (_hourly.isNotEmpty)
            SizedBox(
              height: 120,
              width: double.infinity,
              child: ListView.builder(
                shrinkWrap: false,
                scrollDirection: Axis.horizontal,
                itemCount: _hourly.length,
                itemBuilder: (context, index) {
                  return hourly(index);
                },
              ),
            ),
        ],
      );
    }

    return Scaffold(
      appBar: weather.isNotEmpty
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                "${loc.latitude}N, ${loc.longitude}N",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              actions: weather.isEmpty
                  ? null
                  : [
                      /* Detect Location */
                      IconButton(
                        onPressed: () {
                          googleMap(loc.latitude, loc.longitude);
                        },
                        icon: const Icon(Icons.location_on),
                      ),

                      /* Padding */
                      const SizedBox(width: 7.5),
                    ],
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _callApi(),
          child: SizedBox.expand(
            child: weather.isEmpty
                ? beforeLoad()
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: report(),
                  ),
          ),
        ),
      ),
    );
  }
}
