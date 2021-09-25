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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title!),
        ),
        body: BodyDuScaffold());
  }
}

class BodyDuScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton( //RaisedButton(
              child: Text('Afficher la SnackBar encore'),
              // color: Colors.blue,
              // textColor: Colors.white,
              // color: Colors.blue,
              // textColor: Colors.white,
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // background
                onPrimary: Colors.white, // foreground
              ),
              onPressed: () {
                final SnackBar _snack = SnackBar(
                  content: Text('Ceci est une SnackBar !'),
                  duration: Duration(seconds: 4),
                  backgroundColor: Colors.red,
                  action: SnackBarAction(
                      label: 'Clic',
                      textColor: Colors.white,
                      onPressed: () {
                        //Action à effectuer
                      }),
                );
                // Scaffold.of(context).showSnackBar(_snack);
                // info: 'showSnackBar' is deprecated and shouldn't be used. '
                ScaffoldMessenger.of(context).showSnackBar(_snack);
              }),
        ],
      ),
    );
  }
}
Widget build(BuildContext context) {
  return OutlinedButton(
    onPressed: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A SnackBar has been shown.'),
        ),
      );
    },
    child: const Text('Show SnackBar'),
  );
}