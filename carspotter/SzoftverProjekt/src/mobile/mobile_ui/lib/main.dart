import 'package:flutter/material.dart';
import 'package:mobile_ui/databases/event_database.dart';
import 'package:mobile_ui/databases/note_database.dart';
import 'package:mobile_ui/pages/login_page.dart';
import 'package:mobile_ui/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  try{
       await Firebase.initializeApp();
  }catch (e) {
    print("Firebase initialization failed: $e");
  }
 
  // initialize databases
  await EventDatabase.initialize();
  await EventDatabase().saveFirstLaunchDate();
  
  await NoteDatabase.initialize();
  await NoteDatabase().saveFirstLaunchDate();

  runApp(
    MultiProvider(
      providers: [
        // Theme Provider
        ChangeNotifierProvider(create: (context) => ThemeProvider()),

        // Events Provider
        ChangeNotifierProvider(create: (context) => EventDatabase()),

        // Notes Provider
        ChangeNotifierProvider(create: (context) => NoteDatabase()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarSpotter',
      theme: Provider.of<ThemeProvider>(context).themeData,
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}