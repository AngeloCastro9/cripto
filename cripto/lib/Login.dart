import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Register.dart';
import 'Home.dart';
import 'RouteGenerator.dart';
import 'model/User.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _controllerEmail = TextEditingController(text: "");
  TextEditingController _controllerSenha = TextEditingController(text: "");
  String _messageError = "";

  _validateFields() {
    //Recupera dados dos campos
    String email = _controllerEmail.text;
    String password = _controllerSenha.text;

    if (email.isNotEmpty && email.contains("@")) {
      if (password.isNotEmpty) {
        setState(() {
          _messageError = "";
        });

        User user = User();
        user.email = email;
        user.password = password;

        _logarUser(user);
      } else {
        setState(() {
          _messageError = "Preencha a senha!";
        });
      }
    } else {
      setState(() {
        _messageError = "Preencha o E-mail utilizando @";
      });
    }
  }

  _logarUser(User user) {
    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .signInWithEmailAndPassword(email: user.email, password: user.password)
        .then((firebaseUser) {
      Navigator.pushReplacementNamed(context, "/home");
    }).catchError((error) {
      setState(() {
        _messageError =
            "E-mail ou Senha incorretos, verifique e tente novamente!";
      });
    });
  }

  Future _verificarUserLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    FirebaseUser userLogado = await auth.currentUser();

    if (userLogado != null) {
      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  @override
  void initState() {
    _verificarUserLogado();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Color(0xff1612da)),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                    "images/logo.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerEmail,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "E-mail",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32))),
                  ),
                ),
                TextField(
                  controller: _controllerSenha,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Senha",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32))),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                      child: Text(
                        "Entrar",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      color: Colors.blue,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      onPressed: () {
                        _validateFields();
                      }),
                ),
                Center(
                  child: GestureDetector(
                    child: Text("Não tem conta? cadastre-se!",
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Register()));
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      _messageError,
                      style: TextStyle(color: Colors.red, fontSize: 20),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
