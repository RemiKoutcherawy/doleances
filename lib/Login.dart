import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'package:doleances/Doleances.dart';

class Login extends StatelessWidget {
  final TextEditingController _code = TextEditingController();

  // Widget
  @override
  Widget build(BuildContext context) {
    // Provider
    Doleances doleances = context.watch<Doleances>();
    // Check stored connection, no code needed
    doleances.connect();

    // Widget
    return Scaffold(
      appBar: AppBar(
        title: Text('Doléance connexion',),),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: doleances.connected
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Bienvenue',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Text(
                      doleances.user!.email!,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    ElevatedButton(
                      child: Text('Déconnexion'),
                      onPressed: () {
                        doleances.signOut();
                      },
                    ),
                    ElevatedButton(
                        child: Text('Ajout'),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/ajout');
                        }),
                    ElevatedButton(
                        child: Text('Liste'),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/listeDT');
                        }),
                    doleances.gestion()
                        ? ElevatedButton(
                            child: Text('Configuration'),
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/configuration');
                            })
                        : Container(),
                  ],
                )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _code,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        hintText: 'Code...',
                      ),
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    ElevatedButton(
                      child: Text('Connexion'),
                      onPressed: () {
                        if (_code.text.isEmpty) {
                          _showErrorDialog(
                              context, 'Le code est nécessaire', null);
                        } else {
                          _connect(doleances, context);
                        }
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // Connect in a Future to await Firebase
  Future<void> _connect(Doleances doleances, BuildContext context) async {
    await doleances.connect(codeToTest : _code.text);
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
