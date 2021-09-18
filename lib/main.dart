import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doleances/Doleances.dart';

import 'package:doleances/Login.dart';
import 'package:doleances/Liste.dart';
import 'package:doleances/Ajout.dart';
import 'package:doleances/Configuration.dart';
import 'package:doleances/APropos.dart';

void main() => runApp(
  ChangeNotifierProvider(
    create: (_) => Doleances(),
    child: App(),
  ),);

class App extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // Provider
    Doleances doleances = context.watch<Doleances>();

    return MaterialApp(
          title: 'Doléances',
          theme: appTheme,
          initialRoute: '/',
          routes: {
            '/liste': (context) => Liste(),
            '/ajout': (context) => Ajout(),
            '/login': (context) => Login(),
            '/configuration': (context) => Configuration(),
            '/apropos': (context) => APropos(),
          },
          home: doleances.connected ? Ajout() : Login(),
          // Ajout(), Login(), Liste(), Configuration(),
          debugShowCheckedModeBanner: false,
        );
  }
}

// Theme
final appTheme = ThemeData(
  textTheme: const TextTheme(
    headline1: TextStyle(
      // fontFamily: 'Corben',
      fontWeight: FontWeight.w700,
      fontSize: 32,
      color: Colors.black,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 20,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        primary: Colors.black,
        // backgroundColor: Colors.pinkAccent,
    textStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    side: BorderSide(color: Colors.black, width: 2),
  )),
  // Not used
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(primary: Colors.green),
  ),
);
