import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'loginPage.dart';
import 'homePage.dart';
import 'profilePage.dart';

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
        '/': (context) => LoginPage(),
        '/home': (context) => _buildHomePage(context),
        '/profile': (context) {
          final modalRoute = ModalRoute.of(context);
          Map<String, dynamic>? args;
          if (modalRoute != null && modalRoute.settings.arguments != null) {
            args = modalRoute.settings.arguments as Map<String, dynamic>?;
          }
          final token = args != null && args.containsKey('token') ? args['token'] : '';
          final userId = args != null && args.containsKey('userId') ? args['userId'] : 0;
          final username = args != null && args.containsKey('username') ? args['username'] : '';
          return ProfilePage(token: token, userId: userId, username: username);
        },
      },
    );
  }

  Widget _buildHomePage(BuildContext context) { 
    final modalRoute = ModalRoute.of(context);
    Map<String, dynamic>? args;
    if (modalRoute != null && modalRoute.settings.arguments != null) {
      args = modalRoute.settings.arguments as Map<String, dynamic>?;
    }
    if (args != null && args.containsKey('token')) {
      return HomePage(token: args['token']);
    } else {
      return LoginPage();
    }
  }
}
