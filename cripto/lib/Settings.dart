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
  TextEditingController _controllerNome = TextEditingController();
  File _image;
  String _userIdLogged;
  bool _uploadImage = false;
  String _recoverUrlImage;

  Future _imageRecover(String imageSource) async {
    File imageSelected;
    switch (imageSource) {
      case "camera":
        imageSelected = await ImagePicker.pickImage(source: ImageSource.camera);
        break;
      case "galeria":
        imageSelected =
            await ImagePicker.pickImage(source: ImageSource.gallery);
        break;
    }

    setState(() {
      _image = imageSelected;
      if (_image != null) {
        _uploadImage = true;
        _uploadimage();
      }
    });
  }

  Future _uploadimage() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference rootPath = storage.ref();
    StorageReference file =
        rootPath.child("profile").child(_userIdLogged + ".jpg");

    StorageUploadTask task = file.putFile(_image);

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

    task.onComplete.then((StorageTaskSnapshot snapshot) {
      _recoverUrlimage(snapshot);
    });
  }

  Future _recoverUrlimage(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    _updateUrlimageFirestore(url);

    setState(() {
      _recoverUrlImage = url;
    });
  }

  _updateNameFirestore() {
    String name = _controllerNome.text;
    Firestore db = Firestore.instance;

    Map<String, dynamic> updateData = {"name": name};

    db.collection("users").document(_userIdLogged).updateData(updateData);
  }

  _updateUrlimageFirestore(String url) {
    Firestore db = Firestore.instance;

    Map<String, dynamic> updateData = {"urlimage": url};

    db.collection("users").document(_userIdLogged).updateData(updateData);
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    _userIdLogged = loggedUser.uid;

    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("users").document(_userIdLogged).get();

    Map<String, dynamic> dados = snapshot.data;
    _controllerNome.text = dados["name"];

    if (dados["urlimage"] != null) {
      _recoverUrlImage = dados["urlimage"];
    }
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
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
                        _imageRecover("camera");
                      },
                    ),
                    FlatButton(
                      child: Text("Galeria"),
                      onPressed: () {
                        _imageRecover("galeria");
                      },
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerNome,
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
