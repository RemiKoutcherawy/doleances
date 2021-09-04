import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _message = '';
  bool _connected = false;
  final TextEditingController _mail = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _showConnected();
  }

  void _showErrorDialog(BuildContext context, String title, Exception e) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(
            '${(e as dynamic).message}',
          ),
          actions: <Widget>[
            OutlinedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Check if user is connected
  Future _connect() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _mail.text, password: _password.text);
      User? user = FirebaseAuth.instance.currentUser;
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Close the drawer and return
      } else {
        _message = 'Connecté : ${user!.email}.';
        _connected = true;
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(context, 'Échec de la connexion', e);
      _message = 'Erreur $e';
    }
    setState(() {});
  }

  // Register a new user
  Future _register() async {
    String email = _mail.text;
    String password = _password.text;
    try {
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(email);
      setState(() {
        _message = 'Enregistré';
        // Navigator.pushNamed(context, '/liste');
      });
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(context, 'Échec de l’inscription', e);
      setState(() {
        _message = 'Erreur $e';
      });
    }
  }

  // Disconnect current user
  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      _message = 'Déconnecté';
      _connected = false;
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(context, 'Échec de la déconnexion', e);
      _message = 'Erreur $e';
    }
    setState(() {});
  }

  // Checks and update message in Widget
  void _showConnected() async {
    await Firebase.initializeApp();
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _mail.value = _mail.value.copyWith(
          text: user.email!,
          selection: TextSelection.collapsed(offset: _mail.value.selection.baseOffset),
        );
        _message = 'Connecté : ${user.email}.';
        _connected = true;
      } else {
        _message = 'Non connecté.';
        _connected = false;
      }
    } on FirebaseAuthException catch (e) {
      _message = 'Erreur $e';
    }
    setState(() {});
  }

  // Send an email verification
  void _verifyEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      _message = 'Mail de vérification envoyé.';
    }
    if (user != null && user.emailVerified) {
      await user.sendEmailVerification();
      _message = 'Mail déjà vérifié';
    }
    setState(() {});
  }

  // Widget
  @override
  Widget build(BuildContext context) {
    print(_connected);
    return Scaffold(
      appBar: AppBar(
        title: Text('Doléance Login'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            // padding: EdgeInsets.all(36),
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: _mail,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: 'Mail'),
                validator: (text) => text!.isEmpty ? 'Votre mail est nécessaire' : '',
              ),
              TextFormField(
                controller: _password,
                keyboardType: TextInputType.emailAddress,
                obscureText: true,
                decoration: InputDecoration(hintText: 'Mot de passe'),
                validator: (text) => text!.isEmpty ? 'Le mot de passe est nécessaire' : '',
              ),
              Divider(),
              Center(
                child: Text(
                  _message,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Divider(),
              _connected ?
              ElevatedButton(
                child: Text('Déconnexion'),
                onPressed: () {
                  _signOut();
                },
              ) : ElevatedButton(
                child: Text('Connexion'),
                onPressed: () {
                  _connect();
                },
              ),
              Row(
                // mainAxisAlignment : MainAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    child: Text('Enregistrement'),
                    onPressed: () {
                      _register();
                    },
                  ),
                  ElevatedButton(
                    child: Text('Vérification mail'),
                    onPressed: () {
                      _verifyEmail();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
