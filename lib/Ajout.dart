import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doleances/Doleances.dart';

// A Widget to add a Task
// A StatefulWidget and not StatelessWidget only for Dropdown
class Ajout extends StatefulWidget {
  @override
  _AjoutState createState() => _AjoutState();
}

class _AjoutState extends State<Ajout> {
  // Dropdown list and selected value
  List<DropdownMenuItem<String>> _whatList = [DropdownMenuItem(child: Text('Rien',))];
  String? _whatValue;
  List<DropdownMenuItem<String>> _whereList = [DropdownMenuItem(child: Text('Ici',))];
  String? _whereValue;
  // Controller for Comment TextFormField
  TextEditingController _controllerComment = TextEditingController();
  // Styles
  TextStyle? _style6;
  TextStyle? _style5;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controllerComment.dispose();
    super.dispose();
  }

  // Fetch and set dropdown values from remote
  void setDropdownsValues(Doleances doleances) {

    List<String> whatStringList = doleances.whatStringList;
    List<String> whereStringList = doleances.whereStringList;
    _whatList = whatStringList.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(value: value, child: Text(value, style: _style6,),);
    }).toList();
    _whatValue ?? whatStringList.first;
    if (!whatStringList.contains(_whatValue)) {_whatValue = whatStringList.first;}
    _whereList = whereStringList.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(value: value, child: Text(value, style: _style6,),);
    }).toList();
    _whereValue ?? whereStringList.first;
    if (!whereStringList.contains(_whereValue)) _whereValue = whereStringList.first;
  }

  // Report in a Dialog
  Future<void> _report(msg) async {
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('$msg', style: _style5,),
        );
      });
  }
  // Widget
  @override
  Widget build(BuildContext context) {
    // Provider
    Doleances doleances = context.watch<Doleances>();
    // Styles from context
    _style5 = Theme.of(context).textTheme.headline5;
    _style6 = Theme.of(context).textTheme.headline6;
    // Build _whatList and _whereList from doleances
    setDropdownsValues(doleances);

    // Widget
    return Scaffold(
      appBar: AppBar(
        title: Text('Doléances', style:_style5,),
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              child: Icon(
                Icons.account_circle,
                size: 96,
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 20)),
            ListTile(
              title: Text('Liste',style:_style5,),
              onTap: () {
                Navigator.pushNamed(context, '/liste');
              },
            ),
            ListTile(
              title: Text('Ajout',style: _style5,),
              onTap: () {
                Navigator.pushNamed(context, '/ajout');
              },
            ),
            ListTile(
              title: Text('Configuration',style:_style5,),
              onTap: () {
                Navigator.pushNamed(context, '/configuration');
              },
            ),
            ListTile(
              title: Text('Connexion / Déconnexion',style:_style5,),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
            Divider(),
            ListTile(
              title: Text('A propos',style:_style5,),
              onTap: () {
                Navigator.pushNamed(context, '/apropos');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text("Quel est le problème ?",
            style: _style6,),
          DropdownButton<String>(
            isExpanded: true,
            items: _whatList,
            value: _whatValue,
            onChanged: (String? value) => setState(() => {_whatValue = value!}),
          ),
          Padding(padding: EdgeInsets.only(bottom: 20)),
          Text('Où se situe le problème ?',
            style: _style6,),
          DropdownButton<String>(
            isExpanded: true,
            items: _whereList,
            value: _whereValue,
            onChanged: (String? value) => setState(() => {_whereValue = value!}),
          ),
          Padding(padding: EdgeInsets.only(bottom: 20)),
          Text('Commentaire éventuel ?',
            style: _style6,),
          TextFormField(
            maxLines: 3,
            keyboardType: TextInputType.multiline,
            controller: _controllerComment,
            style: _style6,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text('Ajouter',),
                onPressed: () {
                  String comment = _controllerComment.text;
                  doleances.addTask(_whatValue!, _whereValue!, comment);
                  _report('''Ajoutée : 
$_whatValue / $_whereValue 
$comment''');
                },
              ),

            ],
          ),
          // Text(doleances.message, style:_style5, ),
          ElevatedButton(
            child: Text('Voir liste',),
            onPressed: () {
              Navigator.pushNamed(context, '/liste');
            },
          ),
          doleances.gestion() ? ElevatedButton(
            child: Text('Configurer',),
            onPressed: () {
              Navigator.pushNamed(context, '/configuration');
            },
          ) : Padding(padding: EdgeInsets.only(bottom: 20)),
        ]),
      ),
    );
  }
}
