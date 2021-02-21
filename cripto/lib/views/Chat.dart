import 'package:flutter/material.dart';
import 'package:cripto/model/Chats.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  List<Chats> _listChat = List();

  @override
  void initState() {
    super.initState();

    Chats chats = Chats();
    chats.name = "Ana Clara";
    chats.message = "Olá tudo bem?";
    chats.photoPath =
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-36cd8.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=97a6dbed-2ede-4d14-909f-9fe95df60e30";

    _listChat.add(chats);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: _listChat.length,
        itemBuilder: (context, indice) {
          Chats chats = _listChat[indice];

          return ListTile(
            contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            leading: CircleAvatar(
              maxRadius: 30,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(chats.photoPath),
            ),
            title: Text(
              chats.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(chats.message,
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          );
        });
  }
}
