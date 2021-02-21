import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cripto/model/Chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cripto/model/User.dart';

class ChatTab extends StatefulWidget {
  @override
  _ChatTabState createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  List<Chat> _listChat = List();
  final _controller = StreamController<QuerySnapshot>.broadcast();
  Firestore db = Firestore.instance;
  String _idUserLogged;

  @override
  void initState() {
    super.initState();
    _recoverUserData();
  }

  Stream<QuerySnapshot> _addListenerChats() {
    final stream = db
        .collection("chats")
        .document(_idUserLogged)
        .collection("last_chat")
        .snapshots();

    stream.listen((data) {
      _controller.add(data);
    });
  }

  _recoverUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    _idUserLogged = loggedUser.uid;

    _addListenerChats();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
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
              return Text("Erro ao carregar os dados!");
            } else {
              QuerySnapshot querySnapshot = snapshot.data;

              if (querySnapshot.documents.length == 0) {
                return Center(
                  child: Text(
                    "Você ainda não tem nenhuma mensagem :( ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              }

              return ListView.builder(
                  // itemCount: _listChat.length,
                  itemCount: querySnapshot.documents.length,
                  itemBuilder: (context, indice) {
                    List<DocumentSnapshot> chats =
                        querySnapshot.documents.toList();
                    DocumentSnapshot item = chats[indice];

                    String photoPath = item["photoPath"];
                    String type = item["typeMessage"];
                    String message = item["message"];
                    String name = item["name"];
                    String recipientId = item["recipientId"];

                    User user = User();
                    user.name = name;
                    user.urlImage = photoPath;
                    user.userId = recipientId;

                    return ListTile(
                      onTap: () {
                        Navigator.pushNamed(context, "/messages",
                            arguments: user);
                      },
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      leading: CircleAvatar(
                        maxRadius: 30,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            photoPath != null ? NetworkImage(photoPath) : null,
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(type == "text" ? message : "Imagem...",
                          style: TextStyle(color: Colors.grey, fontSize: 14)),
                    );
                  });
            }
        }
      },
    );
  }
}
