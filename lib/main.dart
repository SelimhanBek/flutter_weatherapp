import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weatherapp/layout/screen.dart';
import 'package:weatherapp/theme/theme.dart';

void main() {
  /* Be sure init */
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /* Disable screen rotation */
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    final currentThemeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Weather App',
      themeMode: currentThemeMode,
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.lightTheme,
      home: const ResponsiveLayout(),
    );
  }
}
