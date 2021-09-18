import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doleances/Doleances.dart';

// Configure choices presented in Ajout.dart
class Configuration extends StatefulWidget {
  @override
  _ConfigurationState createState() => _ConfigurationState();
}

class _ConfigurationState extends State<Configuration> {
  // Dropdown list and selected value
  List<DropdownMenuItem<String>> _whatList = [DropdownMenuItem(child: Text('Rien',))];
  String? _whatValue;
  List<DropdownMenuItem<String>> _whereList = [DropdownMenuItem(child: Text('Ici',))];
  String? _whereValue;
  // Styles
  TextStyle? _style6;
  TextStyle? _style5;
  // Controllers for TextFormFields
  final _controllerWhat = TextEditingController();
  final _controllerWhere = TextEditingController();

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    _controllerWhere.dispose();
    _controllerWhat.dispose();
    super.dispose();
  }

  // Fetch and set dropdown values from Firebase
  void setDropdownsValues(Doleances doleances) async {
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

  // Add String val to Array col in Firebase
  Future<void> _add(TextEditingController controller, Doleances doleances) async {
    String col = '';
    // Retrieve list of strings
    List<String> list = [];
    if (controller == _controllerWhat) {
      list = doleances.whatStringList;
      col = 'what';
    } else if (controller == _controllerWhere) {
      list = doleances.whereStringList;
      col = 'where';
    }
    // Check value to add
    if (controller.text == '') {
      _report('Donnez un nom !');
      return;
    } else if (list.contains(controller.text)) {
      _report('La liste contient déjà ${controller.text}');
      return;
    } else if (!doleances.gestion()) {
      _report('Ajout en local. Les clients n‘ont pas le droit de modifier la configuration.');
    } else {
      // Ok add
      list.add(controller.text);
      _report('Ajout de ${controller.text}');
      // Firebase update will notifyListeners
      doleances.updateChoices(col, list);
      // Immediatly Set local dropdown
      setDropdownsValues(doleances);
    }
  }

  // Remove String val from Array col in Firebase
  Future<void> _remove(TextEditingController controller, Doleances doleances) async {
    String col ='';
    String value = controller.text;
    // Retrieve list of strings from controller
    List<String> list = [];
    if (controller == _controllerWhat) {
      list = doleances.whatStringList;
      col = 'what';
    } else if (controller == _controllerWhere) {
      list = doleances.whereStringList;
      col = 'where';
    }
    // Check value to remove
    if (value == '') {
      _report('Donnez un nom !');
      return;
    } else if (!list.contains(value)) {
      _report('La liste ne contient pas $value');
      return;
    } else {
      // Ok remove from list
      list.remove(value);
      // Local message
      _report('Retrait de $value');
      // Firebase update will notifyListeners
      doleances.updateChoices(col, list);
      // Immediatly Set local dropdown
      setDropdownsValues(doleances);
    }
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
    // Styles
    _style5 = Theme.of(context).textTheme.headline5;
    _style6 = Theme.of(context).textTheme.headline6;
    // Build _whatList and _whereList from doleances
    setDropdownsValues(doleances);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doléances configuration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text('Problèmes possibles',
            style: _style5,),
          DropdownButton<String>(
            isExpanded: true,
            items: _whatList,
            value: _whatValue,
            onChanged: (String? value) => setState(() {
              _whatValue = value!;
              _controllerWhat.text = value;
            }),
          ),
          Text('Saisir le problème possible',
            style: Theme.of(context).textTheme.subtitle1,),
          TextFormField(
            keyboardType: TextInputType.text,
            controller: _controllerWhat,
            style:_style6,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text('Ajouter'),
                onPressed: () {
                  _add(_controllerWhat, doleances);
                },
              ),
              Padding(padding: EdgeInsets.only(left: 20)),
              ElevatedButton(
                child: const Text('Retirer'),
                onPressed: () {
                  _remove(_controllerWhat, doleances);
                },
              ),
            ],
          ),
          Padding(padding: EdgeInsets.only(bottom: 20)),
          Text('Endroits possibles',
            style: _style5,),
          DropdownButton<String>(
            isExpanded: true,
            items: _whereList,
            value: _whereValue,
            onChanged: (String? value) => setState(() {
              _whereValue = value!;
              _controllerWhere.text = value;
            }),
          ),
          Text('Saisir l‘endroit possible',
            style: Theme.of(context).textTheme.subtitle1,),
          TextFormField(
            keyboardType: TextInputType.text,
            controller: _controllerWhere,
            style:_style6,
          ),
          Padding(padding: EdgeInsets.only(bottom: 20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text('Ajouter'),
                onPressed: () {
                  _add( _controllerWhere, doleances);
                },
              ),
              Padding(padding: EdgeInsets.only(left: 20)),
              ElevatedButton(
                child: const Text('Retirer'),
                onPressed: () {
                  _remove(_controllerWhere, doleances);
                },
              ),
            ],
          ),
// Todo trouver le moyen d'afficher les doleances.message en Dialog
//          Text(doleances.message, style:_style5, ),
        ]),
      ),
    );
  }
}

