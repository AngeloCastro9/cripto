import 'package:cripto/Messages.dart';
import 'package:cripto/Settings.dart';
import 'package:flutter/material.dart';

import 'Register.dart';
import 'Home.dart';
import 'Login.dart';
import 'Messages.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => Login());
      case "/login":
        return MaterialPageRoute(builder: (_) => Login());
      case "/register":
        return MaterialPageRoute(builder: (_) => Register());
      case "/home":
        return MaterialPageRoute(builder: (_) => Home());
      case "/settings":
        return MaterialPageRoute(builder: (_) => Settings());
      case "/messages":
        return MaterialPageRoute(builder: (_) => Messages(args));
      default:
        _routeError();
    }
  }

  static Route<dynamic> _routeError() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Tela não encontrada!"),
        ),
        body: Center(
          child: Text("Tela não encontrada!"),
        ),
      );
    });
  }
}
