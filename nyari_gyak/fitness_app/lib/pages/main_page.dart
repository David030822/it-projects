// ignore_for_file: prefer_const_constructors

import 'package:fitness_app/components/square_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '?';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    setState(() {
      _status = 'Pedestrian Status not available';
    });
  }

  void onStepCountError(error) {
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  Future<bool> _checkActivityRecognitionPermission() async {
    bool granted = await Permission.activityRecognition.isGranted;

    if (!granted) {
      granted = await Permission.activityRecognition.request() ==
          PermissionStatus.granted;
    }

    return granted;
  }

  Future<void> initPlatformState() async {
    bool granted = await _checkActivityRecognitionPermission();
    if (!granted) {
      // Tell the user that the app won't work
      return;
    }

    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    (_pedestrianStatusStream.listen(onPedestrianStatusChanged))
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // heading
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Text(
                        'Fitness App',
                        style: GoogleFonts.dmSerifText(
                          fontSize: 36,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child: Text(
                            'Home Page',
                            style: GoogleFonts.dmSerifText(
                              fontSize: 48,
                              color: Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 25.0),
                          child: SquareTile(
                            imagePath: 'assets/images/applogo_step_b.png',
                            height: 50,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Pedometer Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      const Text(
                        'Steps Taken',
                        style: TextStyle(fontSize: 30),
                      ),
                      Text(
                        _steps,
                        style: const TextStyle(fontSize: 60),
                      ),
                      const Divider(
                        height: 100,
                        thickness: 0,
                        color: Colors.white,
                      ),
                      const Text(
                        'Pedestrian Status',
                        style: TextStyle(fontSize: 30),
                      ),
                      Icon(
                        _status == 'walking'
                            ? Icons.directions_walk
                            : _status == 'stopped'
                                ? Icons.accessibility_new
                                : Icons.error,
                        size: 100,
                      ),
                      Center(
                        child: Text(
                          _status,
                          style: _status == 'walking' || _status == 'stopped'
                              ? const TextStyle(fontSize: 30)
                              : const TextStyle(fontSize: 20, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}