import 'package:flutter/material.dart';
import 'dart:io';
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
  String _userLoggedId;
  String _userDestinaitonId;
  Firestore db = Firestore.instance;
  TextEditingController _controllerMensagem = TextEditingController();

  _enviarMensagem() {
    String textMessage = _controllerMensagem.text;
    if (textMessage.isNotEmpty) {
      Message message = Message();
      message.userId = _userLoggedId;
      message.message = textMessage;
      message.urlImagem = "";
      message.type = "text";

      //Salvar mensagem para remetente
      _saveMessage(_userLoggedId, _userDestinaitonId, message);

      //Salvar mensagem para o destinatário
      _saveMessage(_userDestinaitonId, _userLoggedId, message);
    }
  }

  _saveMessage(String senderId, String recipientId, Message msg) async {
    await db
        .collection("messages")
        .document(senderId)
        .collection(recipientId)
        .add(msg.toMap());

    _controllerMensagem.clear();
  }

  _sendImage() async {
    File selectedImage;
    selectedImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    _uploadImage = true;
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference rootPath = storage.ref();
    StorageReference file = rootPath
        .child("messages")
        .child(_userLoggedId)
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
      _recoverImageUrl(snapshot);
    });
  }

  Future _recoverImageUrl(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();

    Message message = Message();
    message.userId = _userLoggedId;
    message.message = "";
    message.urlImagem = url;
    message.type = "image";

    //Salvar mensagem para remetente
    _saveMessage(_userLoggedId, _userDestinaitonId, message);

    //Salvar mensagem para o destinatário
    _saveMessage(_userDestinaitonId, _userLoggedId, message);
  }

  _recoverUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    _userLoggedId = loggedUser.uid;

    _userDestinaitonId = widget.contact.userId;
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
                controller: _controllerMensagem,
                autofocus: true,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Digite uma mensagem...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32)),
                    prefixIcon: _uploadImage
                        ? CircularProgressIndicator()
                        : IconButton(
                            icon: Icon(Icons.camera_alt),
                            onPressed: _sendImage)),
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
            onPressed: _enviarMensagem,
          )
        ],
      ),
    );

    var stream = StreamBuilder(
      stream: db
          .collection("messages")
          .document(_userLoggedId)
          .collection(_userDestinaitonId)
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
                      //recupera mensagem
                      List<DocumentSnapshot> messages =
                          querySnapshot.documents.toList();
                      DocumentSnapshot item = messages[indice];

                      double larguraContainer =
                          MediaQuery.of(context).size.width * 0.8;

                      //Define cores e alinhamento
                      Alignment alignment = Alignment.centerRight;
                      Color cor = Color(0xffd2ffa5);
                      if (_userLoggedId != item["userId"]) {
                        alignment = Alignment.centerLeft;
                        cor = Colors.white;
                      }

                      return Align(
                        alignment: alignment,
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
                                : Image.network(item["urlimage"]),
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
