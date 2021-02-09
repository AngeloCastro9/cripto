import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Home.dart';
import 'Login.dart';
import 'RouteGenerator.dart';
import 'dart:io';

final ThemeData temaIOS = ThemeData(
  primaryColor: Color(0xff1612da),
  accentColor: Colors.blue,
);

final ThemeData temaPadrao = ThemeData(
  primaryColor: Color(0xff1612da),
  accentColor: Colors.blue,
);

void main() {
  runApp(MaterialApp(
    home: Login(),
    theme: Platform.isIOS ? temaIOS : temaPadrao,
    onGenerateRoute: RouteGenerator.generateRoute,
    initialRoute: "/",
    debugShowCheckedModeBanner: false,
  ));
}
