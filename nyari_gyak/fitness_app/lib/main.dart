import 'package:fitness_app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.removeAfter(initialization);

  runApp(const MyApp());
}

Future initialization(BuildContext? context) async {
  await Future.delayed(const Duration(seconds: 3));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}