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
    return MaterialApp(
      title: 'Doléances',
      theme: appTheme,
      home: DefaultTabController(
        length: 5,
        initialIndex: 2,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight * 2),
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                ),
                child: TabBar(
                  tabs: [
                    Text("Liste",),
                    Text("Ajout",),
                    Text("Login",),
                    Text("Conf.",),
                    Text("Aide",),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              ListeDataTable(),
              Ajout(),
              Login(),
              Configuration(),
              APropos(),
            ],
          ),
        ),
      ),

      // Ajout(), Login(), Liste(), Configuration(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Theme
final appTheme = ThemeData(
  // For TabBar
  tabBarTheme: TabBarTheme(
    // indicatorSize: TabBarIndicatorSize.tab,
    labelPadding: EdgeInsets.all(12),
    labelColor: Colors.black,
    unselectedLabelColor: Colors.grey,
    labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    unselectedLabelStyle: TextStyle(fontSize: 18),
  ),

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
    dividerThickness: 1,
  ),
  dividerTheme: DividerThemeData(
    color: Colors.black,
    thickness: 1,
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
