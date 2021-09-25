import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doleances/Doleances.dart';

import 'package:doleances/Login.dart';
import 'package:doleances/ListeDataTable.dart';
import 'package:doleances/Ajout.dart';
import 'package:doleances/Configuration.dart';
import 'package:doleances/APropos.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (_) => Doleances(),
        child: App(),
      ),
    );

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
        '/listeDT': (context) => ListeDataTable(),
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
  // For AppBar
  appBarTheme: AppBarTheme(
      toolbarTextStyle: TextStyle(
        fontSize: 24,
      ),
      titleTextStyle: TextStyle(
        fontSize: 24,
      )),

  // For Dialog
  dialogTheme: DialogTheme(  //).copyWith(
    titleTextStyle: TextStyle(fontSize: 22, color: Colors.black, ),
    contentTextStyle: TextStyle(fontSize: 20, color: Colors.black, ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),

  // For text()
  textTheme: TextTheme(
    bodyText2: TextStyle(
      fontSize: 18,
      color: Colors.black,
    ),
    // For dropdown hint
    subtitle1: TextStyle(
      fontSize: 18,
      color: Colors.grey,
    ),
  ),

  // For DataTable
  dataTableTheme: DataTableThemeData(
    headingTextStyle: TextStyle(
      fontSize: 20,
      color: Colors.black,
      fontWeight: FontWeight.w600,
    ),
    dataTextStyle: TextStyle(
      fontSize: 18,
      color: Colors.black,
      fontWeight: FontWeight.w500,
    ),
    dividerThickness: 2,
  ),
  dividerTheme: DividerThemeData(
    color: Colors.black,
    thickness: 2,
  ),

  // For ElevatedButton
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      primary: Colors.pinkAccent,
      textStyle: const TextStyle(
        fontSize: 24,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  ),
);
