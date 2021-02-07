import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Home.dart';
import 'Login.dart';

void main() {
  runApp(MaterialApp(
    home: Login(),
    theme: ThemeData(
        primaryColor: Color(0xff1612da), accentColor: Color(0xff40e0d0)),
    debugShowCheckedModeBanner: false,
  ));
}
