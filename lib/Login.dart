import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'package:doleances/Doleances.dart';

class Login extends StatelessWidget {
  final TextEditingController _code = TextEditingController();

  // Widget
  @override
  Widget build(BuildContext context) {
    // Login.dart is listening to Doleances
    Doleances doleances = Provider.of<Doleances>(context, listen: true);
    if (!doleances.connected){
      // Look for stored code to connect automatically
      doleances.connect();
    }

    // Widget
    return Scaffold(
      appBar: AppBar(
        title: Text('Doléances connexion',),),
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
                      'Connecté en tant que',
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
                    Padding(padding: EdgeInsets.only(bottom: 40)),
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
                    ElevatedButton(
                        child: Text('À propos'),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/apropos');
                        }),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Bienvenue',
                      style: Theme.of(context).textTheme.headline5,
                    ),
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
    // Show waiting progress indicator
    BuildContext? dialogContext;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        dialogContext = context;
        return Dialog(
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const CircularProgressIndicator(),
              const Text("Connexion"),
            ],
          ),
        );
      },
    );

    // Trim trailing spaces from code
    await doleances.connect(codeToTest : _code.text.trim());

    // Close waiting progress indicator
    Navigator.pop(dialogContext!);

    if (!doleances.connected) {
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
