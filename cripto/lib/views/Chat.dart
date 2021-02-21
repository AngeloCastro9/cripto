import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cripto/model/Chats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  List<Chats> _chatList = List();
  final _controller = StreamController<QuerySnapshot>.broadcast();
  Firestore db = Firestore.instance;
  String _userIdLogged;

  @override
  void initState() {
    super.initState();
    _recoverUserData();
  }

  Stream<QuerySnapshot> _addListenerChat() {
    final stream = db
        .collection("chats")
        .document(_userIdLogged)
        .collection("last_chat")
        .snapshots();

    stream.listen((datas) {
      _controller.add(datas);
    });
  }

  _recoverUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    _userIdLogged = loggedUser.uid;

    _addListenerChat();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _controller.stream,
      // ignore: missing_return
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando chats"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text("Erro ao carregar os datas!");
            } else {
              QuerySnapshot querySnapshot = snapshot.data;

              if (querySnapshot.documents.length == 0) {
                return Center(
                  child: Text(
                    "Você não tem nenhuma mensagem ainda :( ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              }

              return ListView.builder(
                  itemCount: _chatList.length,
                  itemBuilder: (context, indice) {
                    List<DocumentSnapshot> chats =
                        querySnapshot.documents.toList();
                    DocumentSnapshot item = chats[indice];

                    String urlImage = item["photoPath"];
                    String typeMessage = item["typeMessage"];
                    String message = item["message"];
                    String name = item["name"];

                    return ListTile(
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      leading: CircleAvatar(
                        maxRadius: 30,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            urlImage != null ? NetworkImage(urlImage) : null,
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                          typeMessage == "text" ? message : "Imagem...",
                          style: TextStyle(color: Colors.grey, fontSize: 14)),
                    );
                  });
            }
        }
      },
    );
  }
}
