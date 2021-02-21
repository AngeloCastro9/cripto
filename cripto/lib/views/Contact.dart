import 'package:flutter/material.dart';
import 'package:cripto/model/Chats.dart';
import 'package:cripto/model/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Contact extends StatefulWidget {
  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  String _userLoggedId;
  String _userEmailLogged;

  Future<List<User>> _recuperarContatos() async {
    Firestore db = Firestore.instance;

    QuerySnapshot querySnapshot = await db.collection("users").getDocuments();

    List<User> listaUsuarios = List();
    for (DocumentSnapshot item in querySnapshot.documents) {
      var dados = item.data;
      if (dados["email"] == _userEmailLogged) continue;

      User user = User();
      user.email = dados["email"];
      user.name = dados["name"];
      user.urlImagem = dados["urlImagem"];

      listaUsuarios.add(user);
    }

    return listaUsuarios;
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    _userLoggedId = loggedUser.uid;
    _userEmailLogged = loggedUser.email;
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
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
                        backgroundImage: user.urlImagem != null
                            ? NetworkImage(user.urlImagem)
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
