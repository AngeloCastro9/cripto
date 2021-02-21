class User {
  String _userId;
  String _name;
  String _email;
  String _urlImage;
  String _password;

  User();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {"name": this.name, "email": this.email};

    return map;
  }

  String get userId => _userId;

  set userId(String value) {
    _userId = value;
  }

  String get password => _password;

  set password(String value) {
    _password = value;
  }

  String get urlImage => _urlImage;

  set urlImage(String value) {
    _urlImage = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }
}
