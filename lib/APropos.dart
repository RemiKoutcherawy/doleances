import 'package:flutter/material.dart';

class APropos extends StatelessWidget {
  static const String _message = '''
Doléances est un suivi de travaux.
Tout client peut ajouter une doléance, un signalement.
Tout client peut voir liste partagée.
Seule la gestionnaire peut enregistrer comme prioritaire, terminé, ou supprimer une doléance.
Dans la liste les doléances sont en blanc, en orange si prioritaire, en vert si traité. 
RGPD : aucune information personnelle n'est collectée, le code a pour seule finalité de minimiser le spam.
''';
  static const TextStyle style = TextStyle(fontSize: 20,);

  // Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doléance à propos'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Text(
            _message,
          ),
          OutlinedButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ]),
      ),
    );
  }
}
