import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tabs with no Drawer',
      home: Home(title: 'Tabs with no Drawer'),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key? key, this.title= 'Title'}) : super(key: key);
  final String title;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home, color: Colors.white),
            label: 'Accueil'
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.group, color: Colors.white),
            label: 'Mon compte',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book, color: Colors.white),
            label: 'Statistiques',
          ),
        ],
        backgroundColor: Colors.red,
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('$index: Accueil'),
                      ],
                    ),
                  ));
            });
          case 1:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('$index: Mon compte'),
                      ],
                    ),
                  ));
            });
          case 2:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('$index: Statistiques'),
                      ],
                    ),
                  ));
            });

          default:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('$index: Accueil'),
                      ],
                    ),
                  ));
            });
        }
      },
    );
  }
}
