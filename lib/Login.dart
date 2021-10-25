import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'package:doleances/Doleances.dart';

class Login extends StatelessWidget {
  final TextEditingController _mail = TextEditingController();

  // Widget
  @override
  Widget build(BuildContext context) {
    // Login.dart is listening to Doleances
    Doleances doleances = Provider.of<Doleances>(context, listen: true);
    if (!doleances.connected){
      // Look for stored mail to connect automatically
      doleances.connect();
    }

    // Widget
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: doleances.connected
          // Connected
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
                    ],
                )
          // Not connected
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Bienvenue',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    ElevatedButton(
                      child: Text('Connexion client'),
                      onPressed: () {
                          _connect(doleances, context, 'client@doléances.fr');
                      },
                    ),
                    Text(
                      'ou, via le mail de gestion, que vous pouvez choisir en recompilant l‘application',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    TextFormField(
                      controller: _mail,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        hintText: 'Mail...',
                      ),
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    ElevatedButton(
                      child: Text('Connexion gestion'),
                      onPressed: () {
                        String mail = _mail.text.trim();
                        _connect(doleances, context, mail);
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // Connect in a Future to await Firebase
  Future<void> _connect(Doleances doleances, BuildContext context, String mail) async {
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

    await doleances.connect(mailToTest : mail);

    // Close waiting progress indicator
    Navigator.pop(dialogContext!);

    if (!doleances.connected) {
      _showErrorDialog(context, 'Mail inconnu', null);
    }
  }

  Future<void> _showErrorDialog(BuildContext context, String title, Exception? e) async {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(
            (e != null) ? '${(e as dynamic).message}' : 'Entrez le mail...',
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
