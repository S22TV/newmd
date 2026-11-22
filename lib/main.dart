import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'ui_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MDPay - Төлбөрийн Платформ',
      debugShowCheckedModeBanner: false,
      theme: MdpTheme.buildDarkTheme(),
      home: const SplashScreen(),
    );
  }
}
