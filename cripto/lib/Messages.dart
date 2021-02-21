import 'package:flutter/material.dart';
import 'dart:io';
import 'model/Chats.dart';
import 'model/Message.dart';
import 'model/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class Messages extends StatefulWidget {
  User contact;

  Messages(this.contact);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  File _image;
  bool _imageUpload = false;
  String _userIdLogged;
  String _userIdRecipient;
  Firestore db = Firestore.instance;
  TextEditingController _messageController = TextEditingController();

  _enviarMessage() {
    String messageText = _messageController.text;
    if (messageText.isNotEmpty) {
      Message message = Message();
      message.userId = _userIdLogged;
      message.message = messageText;
      message.urlImagem = "";
      message.type = "text";

      //Salvar message para remetente
      _saveMessage(_userIdLogged, _userIdRecipient, message);

      //Salvar message para o destinatário
      _saveMessage(_userIdRecipient, _userIdLogged, message);

      //Salvar conversa
      _saveChats(message);
    }
  }

  _saveChats(Message msg) {
    //Salvar conversa remetente
    Chats cRemetente = Chats();
    cRemetente.senderId = _userIdLogged;
    cRemetente.recipientId = _userIdRecipient;
    cRemetente.message = msg.message;
    cRemetente.name = widget.contact.name;
    cRemetente.photoPath = widget.contact.urlImagem;
    cRemetente.typeMessage = msg.type;
    cRemetente.save();

    //Salvar conversa destinatario
    Chats cDestinatario = Chats();
    cDestinatario.senderId = _userIdRecipient;
    cDestinatario.recipientId = _userIdLogged;
    cDestinatario.message = msg.message;
    cDestinatario.name = widget.contact.name;
    cDestinatario.photoPath = widget.contact.urlImagem;
    cDestinatario.typeMessage = msg.type;
    cDestinatario.save();
  }

  _saveMessage(String idRemetente, String idDestinatario, Message msg) async {
    await db
        .collection("messages")
        .document(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap());

    //Limpa text
    _messageController.clear();
  }

  _sendPhoto() async {
    File sellectedImage;
    sellectedImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    _imageUpload = true;
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference rootFolder = storage.ref();
    StorageReference file = rootFolder
        .child("messages")
        .child(_userIdLogged)
        .child(imageName + ".jpg");

    //Upload da image
    StorageUploadTask task = file.putFile(sellectedImage);

    //Controlar progresso do upload
    task.events.listen((StorageTaskEvent storageEvent) {
      if (storageEvent.type == StorageTaskEventType.progress) {
        setState(() {
          _imageUpload = true;
        });
      } else if (storageEvent.type == StorageTaskEventType.success) {
        setState(() {
          _imageUpload = false;
        });
      }
    });

    //Recuperar url da image
    task.onComplete.then((StorageTaskSnapshot snapshot) {
      _recoverUrlImage(snapshot);
    });
  }

  Future _recoverUrlImage(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();

    Message message = Message();
    message.userId = _userIdLogged;
    message.message = "";
    message.urlImagem = url;
    message.type = "image";

    //Salvar message para remetente
    _saveMessage(_userIdLogged, _userIdRecipient, message);

    //Salvar message para o destinatário
    _saveMessage(_userIdRecipient, _userIdLogged, message);
  }

  _recoverUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    _userIdLogged = loggedUser.uid;

    _userIdRecipient = widget.contact.userId;
  }

  @override
  void initState() {
    super.initState();
    _recoverUserData();
  }

  @override
  Widget build(BuildContext context) {
    var messageBox = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: TextField(
                controller: _messageController,
                autofocus: true,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Digite uma message...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32)),
                    prefixIcon: _imageUpload
                        ? CircularProgressIndicator()
                        : IconButton(
                            icon: Icon(Icons.camera_alt),
                            onPressed: _sendPhoto)),
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: Color(0xff1612da),
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
            mini: true,
            onPressed: _enviarMessage,
          )
        ],
      ),
    );

    var stream = StreamBuilder(
      stream: db
          .collection("messages")
          .document(_userIdLogged)
          .collection(_userIdRecipient)
          .snapshots(),
      // ignore: missing_return
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando mensagens"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            QuerySnapshot querySnapshot = snapshot.data;

            if (snapshot.hasError) {
              return Expanded(
                child: Text("Erro ao carregar os dados!"),
              );
            } else {
              return Expanded(
                child: ListView.builder(
                    itemCount: querySnapshot.documents.length,
                    itemBuilder: (context, indice) {
                      //recupera message
                      List<DocumentSnapshot> messages =
                          querySnapshot.documents.toList();
                      DocumentSnapshot item = messages[indice];

                      double widthContainer =
                          MediaQuery.of(context).size.width * 0.8;

                      //Define cores e alignments
                      Alignment alignment = Alignment.centerRight;
                      Color color = Color(0xffd2ffa5);
                      if (_userIdLogged != item["userId"]) {
                        alignment = Alignment.centerLeft;
                        color = Colors.white;
                      }

                      return Align(
                        alignment: alignment,
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Container(
                            width: widthContainer,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: color,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: item["type"] == "text"
                                ? Text(
                                    item["message"],
                                    style: TextStyle(fontSize: 18),
                                  )
                                : Image.network(item["urlImage"]),
                          ),
                        ),
                      );
                    }),
              );
            }
            break;
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(
                maxRadius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: widget.contact.urlImagem != null
                    ? NetworkImage(widget.contact.urlImagem)
                    : null),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(widget.contact.name),
            )
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/bg.png"), fit: BoxFit.cover)),
        child: SafeArea(
            child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              stream,
              messageBox,
            ],
          ),
        )),
      ),
    );
  }
}
