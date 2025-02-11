import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:news_app/firebase_options.dart';
import 'package:news_app/view/screens/loginpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather Hub',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.white, // Header background color
        scaffoldBackgroundColor: Colors.white,
        dialogBackgroundColor: Colors.white,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white, // Button text color
          ),
        ),
        colorScheme: ColorScheme.light(
          primary: Colors.white, // **Header background color**
          onPrimary: Colors.white, // **Header text color**
          surface: Colors.white,
          onSurface: Colors.black,
        ),
      ),
      home: const LoginPage(),
    );
  }
}
