import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  String _senderId;
  String _recipientId;
  String _name;
  String _message;
  String _photoPath;
  String _typeMessage; //texto ou imagem
  bool _wasRead;

  Chat();

  save() async {
    Firestore db = Firestore.instance;
    await db
        .collection("chats")
        .document(this.senderId)
        .collection("last_chat")
        .document(this.recipientId)
        .setData(this.toMap());
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "senderId": this.senderId,
      "recipientId": this.recipientId,
      "name": this.name,
      "message": this.message,
      "photoPath": this.photoPath,
      "typeMessage": this.typeMessage,
      "wasRead": this.wasRead,
    };

    return map;
  }

  String get senderId => _senderId;

  set senderId(String value) {
    _senderId = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get message => _message;

  String get photoPath => _photoPath;

  set photoPath(String value) {
    _photoPath = value;
  }

  set message(String value) {
    _message = value;
  }

  String get recipientId => _recipientId;

  set recipientId(String value) {
    _recipientId = value;
  }

  String get typeMessage => _typeMessage;

  set typeMessage(String value) {
    _typeMessage = value;
  }

  bool get wasRead => _wasRead;

  set wasRead(bool value) {
    _wasRead = value;
  }
}
