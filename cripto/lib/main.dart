import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Home.dart';

void main() {
  Firestore.instance
      .collection("users")
      .document("001")
      .setData({"name": "Teste"});

  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}
