import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cripto/views/ContactsTab.dart';
import 'package:cripto/views/ChatTab.dart';
import 'dart:io';
import 'Login.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<String> itensMenu = ["Configurações", "Deslogar"];
  String _userEmail = "";

  Future _recoverUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();

    setState(() {
      _userEmail = loggedUser.email;
    });
  }

  Future _verifyUserLogged() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    FirebaseUser loggedUser = await auth.currentUser();

    if (loggedUser == null) {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  void initState() {
    super.initState();
    _verifyUserLogged();
    _recoverUserData();
    _tabController = TabController(length: 2, vsync: this);
  }

  _chooseMenuItem(String chosemItem) {
    switch (chosemItem) {
      case "Configurações":
        Navigator.pushNamed(context, "/settings");
        break;
      case "Deslogar":
        _logoff();
        break;
    }
  }

  _logoff() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();

    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cripto"),
        elevation: Platform.isIOS ? 0 : 4,
        bottom: TabBar(
          indicatorWeight: 4,
          labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          controller: _tabController,
          indicatorColor: Platform.isIOS ? Colors.grey[400] : Colors.white,
          tabs: <Widget>[
            Tab(
              text: "Conversas",
            ),
            Tab(
              text: "Contatos",
            )
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _chooseMenuItem,
            itemBuilder: (context) {
              return itensMenu.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[ChatTab(), ContactsTab()],
      ),
    );
  }
}
