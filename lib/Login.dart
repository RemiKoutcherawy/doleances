import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _message = '';
  bool _connected = false;
  final TextEditingController _code = TextEditingController();

  @override
  void initState() {
    super.initState();
    _showConnected();
  }

  Future<void> _showErrorDialog(BuildContext context, String title, Exception? e) async {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(
            (e != null) ? '${(e as dynamic).message}' : 'Entrez le code...',
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
      // 3 registered profiles, 3 codes, not in clear, this is opensource !
      // Hash would be overkill just to choose between profiles.
      if (_code.text.contains('test')) {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: 'test@doléances.fr', password: _code.text);
      } else if (_code.text.contains('s')) {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: 'client@doléances.fr', password: _code.text);
      } else if (_code.text.contains('S')) {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: 'gestion@doléances.fr', password: _code.text);
      }
      User? user = FirebaseAuth.instance.currentUser;
      if (Navigator.of(context).canPop()) {
        // Navigator.of(context).pop(); // Close the drawer and return
        Navigator.pushReplacementNamed(context, '/adding');

      } else {
        _message = 'Connecté : ${user!.email}.';
        _connected = true;
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(context, 'Échec de la connexion', e);
      _message = 'Erreur ${(e as dynamic).message}';
    }
    setState(() {});
  }

  // Disconnect current user
  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      _message = 'Déconnecté';
      _connected = false;
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(context, 'Échec de la déconnexion', e);
      _message = 'Erreur ${(e as dynamic).message}';
    }
    setState(() {});
  }

  // Checks and update message in Widget
  void _showConnected() async {
    try {
      await Firebase.initializeApp(); // For testing Login directly
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _message = 'Connecté : ${user.email}';
        _connected = true;
      } else {
        _message = 'Non connecté.';
        _connected = false;
      }
    } on FirebaseAuthException catch (e) {
      _message = 'Erreur ${(e as dynamic).message}';
    }
    setState(() {});
  }

  // Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bienvenue',
                style: Theme.of(context).textTheme.headline1,
              ),
              TextFormField(
                controller: _code,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(hintText: 'Code...',),
                style: Theme.of(context).textTheme.headline1,
              ),
              Divider(),
              Center(
                child: Text(
                  _message,
                  style: Theme.of(context).textTheme.headline1,
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              _connected ?
              ElevatedButton(
                child: Text('Déconnexion'),
                onPressed: () {
                  _signOut();
                },
              ) : ElevatedButton(
                child: Text('Connexion'),
                onPressed: () {
                  if (_code.text.isEmpty) {
                    _showErrorDialog(context, 'Le code est nécessaire', null);
                  } else {
                    _connect();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
