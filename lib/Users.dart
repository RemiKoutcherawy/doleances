import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Used to register users
void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Users(title: 'Verification des utilisateurs'),
    );
  }
}

class Users extends StatefulWidget {
  Users({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {
  String _message = '';
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  // Style
  static const TextStyle style = TextStyle(fontSize: 20,);

  @override
  void initState() {
    super.initState();
    _isConnected();
  }

  void _showErrorDialog(BuildContext context, String title, Exception e) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title,style:style,),
          content: Text('${(e as dynamic).message}',style:style,),
          actions: <Widget>[
            OutlinedButton(
              child: Text('OK',style:style),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _connect() async {
    String email = _email.text;
    String password = _password.text;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String verified = user.emailVerified ? 'mail vérifié' : 'mail non vérifié';
        _message = 'Connecté ${user.email} $verified';
      } else {
        _message = 'Pas d\'utilisateur';
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(context, 'Échec ', e);
      _message = 'Erreur ${(e as dynamic).message}';
    }
    setState(() {});
  }

  Future<void> _register() async {
    String email = _email.text;
    String password = _password.text;
    try {
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(email);
      setState(() {
        _message = 'Enregistré';
      });
    } on FirebaseException catch (e) {
      _showErrorDialog(context, 'Échec de l’inscription', e);
      setState(() {
        _message = 'Erreur ${(e as dynamic).message}';
      });
    }
  }

  Future<void> _disconnect() async {
    try {
      await FirebaseAuth.instance.signOut();
      _message = 'Déconnecté';
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(context, 'Échec de la déconnexion', e);
      _message = 'Erreur ${(e as dynamic).message}';
    }
    setState(() {});
  }

  Future<void> _isConnected() async {
    try {
      await Firebase.initializeApp();
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _email.value = _email.value.copyWith(
          text: user.email ?? 'Client sans mail?',
        );
        _message = 'Connecté ${user.email}';
      }
    } on Exception catch (e) {
      _message = 'Erreur ${(e as dynamic).message}';
    }
    setState(() {});
  }

  Future<void> _verifyEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (!user.emailVerified) {
        try {
          await user.sendEmailVerification();
          _message = 'Mail de vérification envoyé';
          // Beware
          // [ERROR:flutter/lib/ui/ui_dart_state.cc(199)] Unhandled Exception:
          // [firebase_auth/too-many-requests]
          // We have blocked all requests from this device due to unusual activity. Try again later.
        } on FirebaseAuthException catch (e) {
          _showErrorDialog(context, 'Échec', e);
          _message = 'Erreur ${(e as dynamic).message}';
        }
      } else {
        _message = 'Mail déjà vérifié.';
      }
      setState(() {});
    }
  }

  Future<void> _passwordChange() async {
    String password = _password.text;
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.updatePassword(password);
        _message = 'Mot de passe changé.';
      } on FirebaseAuthException catch (e) {
        _showErrorDialog(context, 'Échec', e);
        _message = 'Erreur ${(e as dynamic).message}';
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users Login',),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: 'Mail'),
              ),
              TextFormField(
                controller: _password,
                keyboardType: TextInputType.visiblePassword,
                // obscureText: true,
                decoration: InputDecoration(hintText: 'Mot de passe'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    child: Text('Connexion',style:style),
                    onPressed: () {
                      _connect();
                    },
                  ),
                  ElevatedButton(
                    child: Text('Déconnexion',style:style),
                    onPressed: () {
                      _disconnect();
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    child: Text('Enregistrement',style:style),
                    onPressed: () {
                      _register();
                    },
                  ),
                  ElevatedButton(
                    child: Text('Mail vérification',style:style),
                    onPressed: () {
                      _verifyEmail();
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    child: Text('Changement mot de passe',style:style),
                    onPressed: () {
                      _passwordChange();
                    },
                  ),
                ],
              ),
              Divider(),
              Center(
                child: Text(_message,style:style,),
              )
            ],
          ),
        ),
      ),
    );
  }
}
