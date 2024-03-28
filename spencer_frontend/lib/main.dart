import 'package:flutter/material.dart';
import 'package:spencer_frontend/screens/auth_check.dart';
import 'package:spencer_frontend/screens/home_screen.dart';
import 'package:spencer_frontend/screens/login_screen.dart';
import 'package:spencer_frontend/screens/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spenser - Expense Tracker',
      theme: ThemeData.dark().copyWith(),
      home: const AuthCheck(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
