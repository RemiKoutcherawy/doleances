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
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  //  Widget for underline
  Container underline2 = Container(
    height: 3.0,
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.blue, width: 3.0,),),
    ),
  );

  // Fetch and set dropdown values from remote
  void setDropdownsValues(Doleances doleances) {
    List<String> whatStringList = doleances.whatStringList;
    List<String> whereStringList = doleances.whereStringList;
    _whatList = whatStringList.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(value: value, child: Text(value,),);
    }).toList();
    _whatValue ?? whatStringList.first;
    if (!whatStringList.contains(_whatValue)) {
      _whatValue = whatStringList.first;
    }
    _whereList = whereStringList.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(value: value, child: Text(value, style: Theme.of(context).textTheme.headline5,),);
    }).toList();
    _whereValue ?? whereStringList.first;
    if (!whereStringList.contains(_whereValue)) {
        _whereValue = whereStringList.first;
    }
  }
  // Widget
  @override
  Widget build(BuildContext context) {
    // Provider
    Doleances doleances = context.watch<Doleances>();
    // Build _whatList and _whereList from doleances
    setDropdownsValues(doleances);

    // Widget
    return Scaffold(
      appBar: AppBar(
        title: Text('Doléances ajout',),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
            children: [
          Text("Quel est le problème ?", style: Theme.of(context).textTheme.headline5,),
          DropdownButton<String>(
            style: Theme.of(context).textTheme.headline5,
            underline: underline2,
            isExpanded: true,
            items: _whatList,
            value: _whatValue,
            onChanged: (String? value) => setState(() => {_whatValue = value!}),
          ),
          Padding(padding: EdgeInsets.only(bottom: 20)),
          Text('Où est le problème ?', style: Theme.of(context).textTheme.headline5,),
          DropdownButton<String>(
            style: Theme.of(context).textTheme.headline5,
            underline: underline2,
            isExpanded: true,
            items: _whereList,
            value: _whereValue,
            onChanged: (String? value) => setState(() => {_whereValue = value!}),
          ),
          Padding(padding: EdgeInsets.only(bottom: 20)),
          Text('Commentaire ?', style: Theme.of(context).textTheme.headline5,),
          TextFormField(
            style: Theme.of(context).textTheme.headline5,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            maxLines: 3,
            keyboardType: TextInputType.multiline,
            controller: _controller,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text('Ajouter',),
                onPressed: () {
                  String comment = _controller.text;
                  doleances.addTask(_whatValue!, _whereValue!, comment);
                  _report('''Ajoutée : 
$_whatValue / $_whereValue 
$comment''');
                },
              ),
            ],
          ),
          Padding(padding: EdgeInsets.only(bottom: 40)),
              // decoration: const InputDecoration(border: OutlineInputBorder()),

              ElevatedButton(
            child: Text('Liste',),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/listeDT');
            },
          ),
          ElevatedButton(
            child: Text('Connexion'),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          doleances.gestion()
              ? ElevatedButton(
                  child: Text('Configuration',),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/configuration');
                  },
                )
              : Padding(padding: EdgeInsets.only(bottom: 20)),
        ]),
      ),
    );
  }

  // Report in a Dialog
  Future<void> _report(msg) async {
    await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('$msg',),
          );
        });
  }
}
