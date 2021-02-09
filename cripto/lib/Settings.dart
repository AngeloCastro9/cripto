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
  TextEditingController _controllerName = TextEditingController();
  File _image;
  String _idLoggedUser;
  bool _uploadImage = false;
  String _recoveryImageUrl;

  Future _recuperarimage(String originImage) async {
    File selectedImage;
    switch (originImage) {
      case "camera":
        selectedImage = await ImagePicker.pickImage(source: ImageSource.camera);
        break;
      case "galeria":
        selectedImage =
            await ImagePicker.pickImage(source: ImageSource.gallery);
        break;
    }

    setState(() {
      _image = selectedImage;
      if (_image != null) {
        _uploadImage = true;
        _uploadimage();
      }
    });
  }

  Future _uploadimage() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference homePath = storage.ref();
    StorageReference file =
        homePath.child("perfil").child(_idLoggedUser + ".jpg");

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
      _recuperarUrlimage(snapshot);
    });
  }

  Future _recuperarUrlimage(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    _updateUrlImageOnFirestore(url);

    setState(() {
      _recoveryImageUrl = url;
    });
  }

  _atualizarNomeFirestore() {
    String nome = _controllerName.text;
    Firestore db = Firestore.instance;

    Map<String, dynamic> updateData = {"nome": nome};

    db.collection("users").document(_idLoggedUser).updateData(updateData);
  }

  _updateUrlImageOnFirestore(String url) {
    Firestore db = Firestore.instance;

    Map<String, dynamic> updateData = {"urlimage": url};

    db.collection("users").document(_idLoggedUser).updateData(updateData);
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    _idLoggedUser = loggedUser.uid;

    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("users").document(_idLoggedUser).get();

    Map<String, dynamic> dados = snapshot.data;
    _controllerName.text = dados["nome"];

    if (dados["urlimage"] != null) {
      _recoveryImageUrl = dados["urlimage"];
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
                    backgroundImage: _recoveryImageUrl != null
                        ? NetworkImage(_recoveryImageUrl)
                        : null),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      child: Text("Câmera"),
                      onPressed: () {
                        _recuperarimage("camera");
                      },
                    ),
                    FlatButton(
                      child: Text("Galeria"),
                      onPressed: () {
                        _recuperarimage("galeria");
                      },
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerName,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
                    /*onChanged: (texto){
                      _atualizarNomeFirestore(texto);
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
                      color: Colors.green,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      onPressed: () {
                        _atualizarNomeFirestore();
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
