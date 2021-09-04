import 'package:flutter/material.dart';

class APropos extends StatelessWidget {
  static const String _message =
'''
Doléances est une application de suivi de travaux.
Tout utilisateur peut ajouter une doléance, un signalement.
La liste est accessible à tous.
La priorité peut être fixeé dans la liste des travaux à faire.
RGPD : seule l'adresse mail est collectée, avec pour seule finalité de minimiser le spam.
''';

  // Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doléance à propos'),
      ),
      body: Container (
        padding: const EdgeInsets.all(20),
        child: Column (
              children: [
                Text( _message,
              ),
              OutlinedButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
              )
            ]
            ),
          ),
      );
  }
}

