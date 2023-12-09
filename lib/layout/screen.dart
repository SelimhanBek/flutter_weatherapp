import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weatherapp/layout/layout_mobile.dart';
import 'package:weatherapp/layout/layout_web.dart';
import 'package:weatherapp/providers/location.dart';
import 'package:weatherapp/resources/global.dart';
import 'package:weatherapp/theme/theme.dart';

class ResponsiveLayout extends ConsumerStatefulWidget {
  const ResponsiveLayout({
    super.key,
  });

  @override
  ResponsiveLayoutState createState() => ResponsiveLayoutState();
}

class ResponsiveLayoutState extends ConsumerState<ResponsiveLayout> {
  /* Load All */
  _load() async {
    /* Check Location Services */
    await ref.read(locationProvider.notifier).checkLocationService();

    /* Is night ? */
    if (AppGlobal.isNight()) {
      ref.read(themeProvider.notifier).changeAppTheme(mode: ThemeMode.dark);
    } else {
      ref.read(themeProvider.notifier).changeAppTheme(mode: ThemeMode.light);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        /* Web Layout */
        if (constraints.maxWidth > 600.0) {
          return const WebScreenLayout();
        }

        /* Mobile Layout */
        return const MobileScreenLayout();
      },
    );
  }
}
