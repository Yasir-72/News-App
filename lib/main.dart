import 'package:flutter/material.dart';
import 'package:news_app/view/screens/RejisterPage.dart';
import 'package:news_app/view/screens/bottomBar.dart';
import 'package:news_app/view/screens/loginpage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const RegisterPage(),
    );
  }
}
