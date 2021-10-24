import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(Login());

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

  Future<void> _showErrorDialog(BuildContext context, String title, Exception e) async {
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
      if (user != null) {
        _message = 'Connecté : ${user!.email}.';
        _connected = true;
      } else {
        _message = 'Déconnecté';
        _connected = false;
        _mail.clear();
        _password.clear();
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
    return MaterialApp(
      theme: appTheme,
      home: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'Enregistrement',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
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
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    _message,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
                const SizedBox(height: 24),
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
          ),
        ),
      ),
    );
  }
}
// Theme
final appTheme = ThemeData(
  // For AppBar
  appBarTheme: AppBarTheme(
      toolbarTextStyle: TextStyle(
        fontSize: 24,
      ),
      titleTextStyle: TextStyle(
        fontSize: 24,
      )),

  // For TabBar
  tabBarTheme: TabBarTheme(
    // indicatorSize: TabBarIndicatorSize.tab,
    labelPadding: EdgeInsets.all(12),
    labelColor: Colors.black,
    unselectedLabelColor: Colors.grey,
    labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    unselectedLabelStyle: TextStyle(fontSize: 18),
  ),

  // For Dialog
  dialogTheme: DialogTheme(
    //).copyWith(
    titleTextStyle: TextStyle(
      fontSize: 22,
      color: Colors.black,
    ),
    contentTextStyle: TextStyle(
      fontSize: 20,
      color: Colors.black,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),

  // For text()
  textTheme: TextTheme(
    bodyText2: TextStyle(
      fontSize: 18,
      color: Colors.black,
    ),
    // For dropdown hint
    subtitle1: TextStyle(
      fontSize: 18,
      color: Colors.grey,
    ),
  ),

  // For DataTable
  dataTableTheme: DataTableThemeData(
    headingTextStyle: TextStyle(
      fontSize: 20,
      color: Colors.black,
      fontWeight: FontWeight.w600,
    ),
    dataTextStyle: TextStyle(
      fontSize: 18,
      color: Colors.black,
      fontWeight: FontWeight.w500,
    ),
    dividerThickness: 1,
  ),
  dividerTheme: DividerThemeData(
    color: Colors.black,
    thickness: 1,
  ),

  // For ElevatedButton
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      primary: Colors.pinkAccent,
      textStyle: const TextStyle(
        fontSize: 24,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  ),
);
