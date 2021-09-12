import 'package:flutter/material.dart';

import 'package:doleances/Login.dart';
import 'package:doleances/Listing.dart';
import 'package:doleances/Adding.dart';
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
        '/listing': (context) => Listing(),
        '/adding': (context) => Adding(),
        '/login': (context) => Login(),
        '/configuration': (context) => Configuration(),
        '/apropos': (context) => APropos(),
      },
      home: Adding(), // Adding(), Login(), Listing(), Configuration(),
      debugShowCheckedModeBanner: false,
    );
  }
}

