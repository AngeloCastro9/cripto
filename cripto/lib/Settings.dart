import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController _nameController = TextEditingController();
  File _image;
  String _idUserLogged;
  bool _uploadImage = false;
  String _recoverUrlImage;

  final picker = ImagePicker();

  Future _recoverImage(String origemImagem) async {
    var pickedFile;

    switch (origemImagem) {
      case "camera":
        pickedFile = await picker.getImage(source: ImageSource.camera);
        break;
      case "galeria":
        pickedFile = await picker.getImage(source: ImageSource.gallery);
        break;
    }

    setState(() {
      if (pickedFile != null) {
        _uploadImage = true;
        _image = File(pickedFile.path);
        _uploadImagem();
      } else {
        print('No image selected.');
      }
    });
  }

  Future _uploadImagem() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference rootFolder = storage.ref();
    StorageReference file =
        rootFolder.child("profile").child(_idUserLogged + ".jpg");

    //Upload da image
    StorageUploadTask task = file.putFile(_image);

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
      _recoveredUrlImage(snapshot);
    });
  }

  Future _recoveredUrlImage(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    _updateUrlImageFirestore(url);

    setState(() {
      _recoverUrlImage = url;
    });
  }

  _updateNameFirestore() {
    String name = _nameController.text;
    Firestore db = Firestore.instance;

    Map<String, dynamic> updateData = {"name": name};

    db.collection("users").document(_idUserLogged).updateData(updateData);
  }

  _updateUrlImageFirestore(String url) {
    Firestore db = Firestore.instance;

    Map<String, dynamic> updateData = {"urlImage": url};

    db.collection("users").document(_idUserLogged).updateData(updateData);
  }

  _recoverUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    _idUserLogged = loggedUser.uid;

    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("users").document(_idUserLogged).get();

    Map<String, dynamic> dados = snapshot.data;
    _nameController.text = dados["name"];

    if (dados["urlImage"] != null) {
      setState(() {
        _recoverUrlImage = dados["urlImage"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _recoverUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(16),
                  child:
                      _uploadImage ? CircularProgressIndicator() : Container(),
                ),
                CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey,
                    backgroundImage: _recoverUrlImage != null
                        ? NetworkImage(_recoverUrlImage)
                        : null),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      child: Text("Câmera"),
                      onPressed: () {
                        _recoverImage("camera");
                      },
                    ),
                    FlatButton(
                      child: Text("Galeria"),
                      onPressed: () {
                        _recoverImage("galeria");
                      },
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _nameController,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
                    /*onChanged: (texto){
                      _updateNameFirestore(texto);
                    },*/
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "Nome",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                      child: Text(
                        "Salvar",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      color: Colors.blue,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      onPressed: () {
                        _updateNameFirestore();
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
