import 'package:flutter/material.dart';

class APropos extends StatelessWidget {
  static const String _message = '''
Doléances est un suivi de travaux.
Tout client peut ajouter une doléance, un signalement.
Tout client peut voir la liste partagée.
Seule le ou la gestionnaire peut :
- enregistrer comme prioritaire, terminé, ou supprimer une doléance
- ajouter un problème possible et un endroit possible.
Dans la liste les doléances sont en blanc, en orange si prioritaire, en vert si traité. 
RGPD : aucune information personnelle n'est collectée, le mail a pour seule finalité d'identifier le gestionnaire.
Vous pouvez définir ce mail en recompilant l'application qui est open source.
''';

  // Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView (
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(_message, style: Theme.of(context).textTheme.headline6,),
                ]
            )
        ),
      ),
    );
  }
}
