import 'package:flutter/material.dart';

import 'package:doleances/Login.dart';
import 'package:doleances/Liste.dart';
import 'package:doleances/Ajout.dart';
import 'package:doleances/Config.dart';
import 'package:doleances/APropos.dart';

void main() => runApp(App());

class App extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doléances',
      initialRoute: '/',
      routes: {
        '/liste': (context) => Liste(),
        '/ajout': (context) => Ajout(),
        '/login': (context) => Login(),
        '/configuration': (context) => Configuration(),
        '/apropos': (context) => APropos(),
      },
      home: Ajout(), // Ajout(), Login(), Liste(), Configuration(),
      debugShowCheckedModeBanner: false,
    );
  }
}

