import 'package:flutter/material.dart';
import 'package:cripto/model/Chats.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  List<Chats> chatList = [
    Chats("Teste", "Testando o teste testado",
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
            subtitle: Text(chat.message,
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          );
        });
  }
}
