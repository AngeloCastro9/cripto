import 'package:flutter/material.dart';
import 'package:cripto/model/Chat.dart';
import 'package:cripto/model/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactsTab extends StatefulWidget {
  @override
  _ContactsTabState createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab> {
  String _userIdLogged;
  String _emailUserLogged;

  Future<List<User>> _recuperarContatos() async {
    Firestore db = Firestore.instance;

    QuerySnapshot querySnapshot = await db.collection("users").getDocuments();

    List<User> listaUsers = List();
    for (DocumentSnapshot item in querySnapshot.documents) {
      var dados = item.data;
      if (dados["email"] == _emailUserLogged) continue;

      User user = User();
      user.userId = item.documentID;
      user.email = dados["email"];
      user.name = dados["name"];
      user.urlImage = dados["urlImage"];

      listaUsers.add(user);
    }

    return listaUsers;
  }

  _recuperarDadosUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser userLogado = await auth.currentUser();
    _userIdLogged = userLogado.uid;
    _emailUserLogged = userLogado.email;
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: _recuperarContatos(),
      // ignore: missing_return
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando contatos"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (_, indice) {
                  List<User> listaItens = snapshot.data;
                  User user = listaItens[indice];

                  return ListTile(
                    onTap: () {
                      Navigator.pushNamed(context, "/messages",
                          arguments: user);
                    },
                    contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    leading: CircleAvatar(
                        maxRadius: 30,
                        backgroundColor: Colors.grey,
                        backgroundImage: user.urlImage != null
                            ? NetworkImage(user.urlImage)
                            : null),
                    title: Text(
                      user.name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  );
                });
            break;
        }
      },
    );
  }
}
