import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:doleances/Doleances.dart';

class Login extends StatelessWidget {
  final TextEditingController _code = TextEditingController();

  // Widget
  @override
  Widget build(BuildContext context) {
    // Provider
    Doleances doleances = context.watch<Doleances>();

    // Widget
    return Scaffold(
      appBar: AppBar(
        title: Text('Doléance connexion',),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Bienvenue',
                style: Theme.of(context).textTheme.headline4,
              ),
              // Don't show TextField if connected
              doleances.connected ? Divider() :
              TextFormField(
                controller: _code,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(hintText: 'Code...',),
                style: Theme.of(context).textTheme.headline4,
              ) ,
              Center(
                 child: doleances.connected ? Text(
                  doleances.user!.email!,
                  style: Theme.of(context).textTheme.headline4,
                ) : Container(),
              ),
              const SizedBox(height: 24,),
              doleances.connected
                  ? ElevatedButton(
                      child: Text('Déconnexion'),
                      onPressed: () {
                        doleances.signOut();
                      },
                    )
                  : ElevatedButton(
                      child: Text('Connexion'),
                      onPressed: () {
                        if (_code.text.isEmpty) {
                          _showErrorDialog(context, 'Le code est nécessaire', null);
                        } else {
                          _connect(doleances, context);
                        }
                      },
                    ),
              doleances.connected
                  ? ElevatedButton(
                      child: Text('Ajout'),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/ajout');
                      })
                  : Container(),
              doleances.connected
                  ? ElevatedButton(
                  child: Text('Liste'),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/listeDT');
                  })
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  // Connect in a Future to await Firebase
  Future<void> _connect(Doleances doleances, BuildContext context) async {
    await doleances.connect(_code.text);
    if (doleances.connected) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // Close the drawer and return
      } else {
        Navigator.pushReplacementNamed(context, '/ajout');
      }
    } else {
      _showErrorDialog(context, 'Mauvais code', null);
    }
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
}
