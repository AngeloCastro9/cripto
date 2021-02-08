import 'package:flutter/material.dart';
import 'package:cripto/model/Chats.dart';

class Chat extends StatefulWidget {
  @override
  _AbaConversasState createState() => _AbaConversasState();
}

class _AbaConversasState extends State<Chat> {
  List<Chats> listaConversas = [
    Chats("Teste", "Testando o teste testado",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-36cd8.appspot.com/o/perfil%2Fperfil2.jpg?alt=media&token=659622c6-4a5d-451a-89b9-05712c64b526"),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: listaConversas.length,
        itemBuilder: (context, indice) {
          Chats conversa = listaConversas[indice];

          return ListTile(
            contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            leading: CircleAvatar(
              maxRadius: 30,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(conversa.caminhoFoto),
            ),
            title: Text(
              conversa.nome,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(conversa.mensagem,
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          );
        });
  }
}
