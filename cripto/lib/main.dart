import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Home.dart';
import 'Login.dart';
import 'RouteGenerator.dart';

void main() {
  runApp(MaterialApp(
    home: Login(),
    theme: ThemeData(primaryColor: Color(0xff1612da), accentColor: Colors.blue),
    onGenerateRoute: RouteGenerator.generateRoute,
    initialRoute: "/login",
    debugShowCheckedModeBanner: false,
  ));
}
