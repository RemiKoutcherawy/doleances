import 'package:flutter/material.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight *2),
            child: SafeArea(
              child: TabBar(
                // labelStyle: TabBarTheme.of(context).labelStyle,
                tabs: [
                  Text("Liste",),
                  Text("Ajout",),
                  Text("Config",),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              Column(
                children: <Widget>[Text("Liste")],
              ),
              Column(
                children: <Widget>[Text("Ajout")],
              ),
              Column(
                children: <Widget>[Text("Configuration")],
              )
            ],
          ),
        ),
      ),
    );
  }
}
final appTheme = ThemeData(
  // For TabBar
  tabBarTheme: TabBarTheme(
    labelColor: Colors.black,
    unselectedLabelColor: Colors.grey,
    labelStyle: TextStyle(fontSize: 24),
    unselectedLabelStyle: TextStyle(fontSize: 24),
  ),
);