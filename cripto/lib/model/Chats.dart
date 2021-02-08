class Chats {
  String _name;
  String _message;
  String _photoPath;

  Chats(this._name, this._message, this._photoPath);

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
}
