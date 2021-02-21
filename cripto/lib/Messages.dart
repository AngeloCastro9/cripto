import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'model/Chat.dart';
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
  bool _uploadImage = false;
  String _userIdLogged;
  String _userIdRecipient;
  Firestore db = Firestore.instance;
  TextEditingController _messageController = TextEditingController();

  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollController = ScrollController();

  _enviarMensagem() {
    String textMessage = _messageController.text;
    if (textMessage.isNotEmpty) {
      Message message = Message();
      message.userId = _userIdLogged;
      message.message = textMessage;
      message.urlImage = "";
      message.type = "text";
      message.data = Timestamp.now().toString();

      //Salvar message para remetente
      _saveMessage(_userIdLogged, _userIdRecipient, message);

      //Salvar message para o destinatário
      _saveMessage(_userIdRecipient, _userIdLogged, message);

      //Salvar conversa
      _saveChat(message);
    }
  }

  _saveChat(Message msg) {
    //Salvar conversa remetente
    Chat cSender = Chat();
    cSender.senderId = _userIdLogged;
    cSender.recipientId = _userIdRecipient;
    cSender.message = msg.message;
    cSender.name = widget.contact.name;
    cSender.photoPath = widget.contact.urlImage;
    cSender.typeMessage = msg.type;
    cSender.save();

    //Salvar conversa destinatario
    Chat cRecipient = Chat();
    cRecipient.senderId = _userIdRecipient;
    cRecipient.recipientId = _userIdLogged;
    cRecipient.message = msg.message;
    cRecipient.name = widget.contact.name;
    cRecipient.photoPath = widget.contact.urlImage;
    cRecipient.typeMessage = msg.type;
    cRecipient.save();
  }

  _saveMessage(String senderId, String recipientId, Message msg) async {
    await db
        .collection("messages")
        .document(senderId)
        .collection(recipientId)
        .add(msg.toMap());

    //Limpa texto
    _messageController.clear();
  }

  _sendoPhoto() async {
    File selectedImage;
    selectedImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    _uploadImage = true;
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference rootFolder = storage.ref();
    StorageReference file = rootFolder
        .child("messages")
        .child(_userIdLogged)
        .child(imageName + ".jpg");

    //Upload da image
    StorageUploadTask task = file.putFile(selectedImage);

    //Controlar progresso do upload
    task.events.listen((StorageTaskEvent storageEvent) {
      if (storageEvent.type == StorageTaskEventType.progress) {
        setState(() {
          _uploadImage = true;
        });
      } else if (storageEvent.type == StorageTaskEventType.success) {
        setState(() {
          _uploadImage = false;
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
    message.urlImage = url;
    message.type = "image";
    message.data = Timestamp.now().toString();

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

    _addListenerMessage();
  }

  Stream<QuerySnapshot> _addListenerMessage() {
    final stream = db
        .collection("messages")
        .document(_userIdLogged)
        .collection(_userIdRecipient)
        .orderBy("data", descending: false)
        .snapshots();

    stream.listen((data) {
      _controller.add(data);
      Timer(Duration(seconds: 1), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _recoverUserData();
  }

  @override
  Widget build(BuildContext context) {
    var caixaMensagem = Container(
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
                style: TextStyle(fontSize: 15),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Digite uma menssagem",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32)),
                    prefixIcon: _uploadImage
                        ? CircularProgressIndicator()
                        : IconButton(
                            icon: Icon(Icons.camera_alt),
                            onPressed: _sendoPhoto)),
              ),
            ),
          ),
          Platform.isIOS
              ? CupertinoButton(
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  onPressed: _enviarMensagem,
                )
              : FloatingActionButton(
                  backgroundColor: Color(0xff1612da),
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  mini: true,
                  onPressed: _enviarMensagem,
                )
        ],
      ),
    );

    var stream = StreamBuilder(
      stream: _controller.stream,
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
              return Text("Erro ao carregar os dados!");
            } else {
              return Expanded(
                child: ListView.builder(
                    controller: _scrollController,
                    itemCount: querySnapshot.documents.length,
                    itemBuilder: (context, indice) {
                      //recupera message
                      List<DocumentSnapshot> mensagens =
                          querySnapshot.documents.toList();
                      DocumentSnapshot item = mensagens[indice];

                      double larguraContainer =
                          MediaQuery.of(context).size.width * 0.8;

                      //Define cores e alinhamentos
                      Alignment alinhamento = Alignment.centerRight;
                      Color cor = Colors.blue;
                      if (_userIdLogged != item["userId"]) {
                        alinhamento = Alignment.centerLeft;
                        cor = Colors.white;
                      }

                      return Align(
                        alignment: alinhamento,
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Container(
                            width: larguraContainer,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: cor,
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
                backgroundImage: widget.contact.urlImage != null
                    ? NetworkImage(widget.contact.urlImage)
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
              caixaMensagem,
            ],
          ),
        )),
      ),
    );
  }
}
