class Message {
  String _userId;
  String _message;
  String _urlImagem;

  String _type;

  Message();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "userId": this.userId,
      "message": this.message,
      "urlImagem": this.urlImagem,
      "type": this.type,
    };

    return map;
  }

  String get type => _type;

  set type(String value) {
    _type = value;
  }

  String get urlImagem => _urlImagem;

  set urlImagem(String value) {
    _urlImagem = value;
  }

  String get message => _message;

  set message(String value) {
    _message = value;
  }

  String get userId => _userId;

  set userId(String value) {
    _userId = value;
  }
}
