import 'package:flutter/material.dart';
import 'auth/screens/splash_screen.dart'; // import splash lu

void main() {
  runApp(const YasahabaApp());
}

class YasahabaApp extends StatelessWidget {
  const YasahabaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yasahaba Wifi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      // app dibuka langsung nyasar kesini buat ngecek auth
      home: const SplashScreen(), 
    );
  }
}