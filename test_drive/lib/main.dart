import 'package:flutter/material.dart';
import 'loginPage.dart';
import 'homePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => _buildHomePage(context),
      },
    );
  }

  Widget _buildHomePage(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('token')) {
      return HomePage(token: args['token']);
    } else {
      return const LoginPage();
    }
  }
}
