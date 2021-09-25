import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;
  final SnackBar _snack = SnackBar(
    content: Text('Ceci est une SnackBar !'),
    duration: Duration(seconds: 4),
    backgroundColor: Colors.red,
    action: SnackBarAction(
        label: 'Clic',
        textColor: Colors.white,
        onPressed: () {
          //Action à effectuer
        }
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title!),
        ),
        body: Builder(builder: (BuildContext context) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // info: 'RaisedButton' is deprecated and shouldn't be used.
                // Use ElevatedButton instead.
                // See the migration guide in flutter.dev/go/material-button-migration-guide).

                ElevatedButton( // )RaisedButton(
                  // RaisedButton(
                  //   color: Colors.red, // background
                  // ElevatedButton(
                  //   style: ElevatedButton.styleFrom(
                  //     primary: Colors.red, // background
                  //     onPrimary: Colors.white, // foreground
                  //   ),
                  onPressed: () {
                    // Scaffold.of(context).showSnackBar(_snack);
                    // info: 'showSnackBar' is deprecated and shouldn't be used. '
                    ScaffoldMessenger.of(context).showSnackBar(_snack);
                  },
                  // color: Colors.blue,
                  // textColor: Colors.white,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue, // background
                    onPrimary: Colors.white, // foreground
                  ),
                  child: Text('Afficher la SnackBar'),
                ),
              ],
            ),
          );
        })
    );
  }
}
