import 'package:flutter/material.dart';
import 'package:cripto/model/Chats.dart';

class Contact extends StatefulWidget {
  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  List<Chats> chatList = [
    Chats("Teste", "testador!",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-36cd8.appspot.com/o/perfil%2Fperfil2.jpg?alt=media&token=659622c6-4a5d-451a-89b9-05712c64b526"),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: chatList.length,
        itemBuilder: (context, indice) {
          Chats chat = chatList[indice];

          return ListTile(
            contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            leading: CircleAvatar(
              maxRadius: 30,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(chat.photoPath),
            ),
            title: Text(
              chat.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          );
        });
  }
}
