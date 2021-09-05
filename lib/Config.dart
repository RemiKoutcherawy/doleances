import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// See https://firebase.flutter.dev/docs/firestore/usage/

// Configure choices presented in Ajout.dart
class Configuration extends StatefulWidget {
  @override
  _ConfigurationState createState() => _ConfigurationState();
}

class _ConfigurationState extends State<Configuration> {
  // Dropdown list and selected value
  List<DropdownMenuItem<String>>? _whereList;
  String? _whereValue;
  List<DropdownMenuItem<String>>? _whatList;
  String? _whatValue;

  // Controllers for TextFormFields
  final _controllerWhere = TextEditingController();
  final _controllerWhat = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateConfiguration();
  }

  // Fetch and sets values in DropDowns
  Future _updateConfiguration() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushNamed(context, '/login');
    }
    CollectionReference configuration = FirebaseFirestore.instance.collection("configuration");
    var doc = await configuration.doc('0P7ZltbztNCsXLZIkDcV').get();
    // doc contains what[] and where[]

    List<String> listWhat = doc.get('what').cast<String>();
    List<DropdownMenuItem<String>> listWhatDropDown =
        listWhat.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
    _whatList = listWhatDropDown;
    _whatValue = listWhat.first; // important

    List<String> listWhere = doc.get('where').cast<String>();
    List<DropdownMenuItem<String>> listWhereDropDown =
        listWhere.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
    _whereList = listWhereDropDown;
    _whereValue = listWhere.first; // important

    setState(() {});
  }

  // Add String val to Arrau col in Firebase
  Future _add(String col, String val) async {
    var configuration = FirebaseFirestore.instance.collection("configuration");
    var doc = await configuration.doc('0P7ZltbztNCsXLZIkDcV').get();

    // col can be 'what' or 'where'
    List<String> list = doc.get(col).cast<String>();
    String msg = '';
    TextEditingController? controller = _getController(col);
    if (controller != null) {
      if (controller.text == '') {
        msg = 'Donnez un nom !';
      } else if (list.contains(controller.text)) {
        msg = 'La liste contient déjà ${controller.text}';
      } else {
        list.add(controller.text);
        doc.reference.update({col: list});
        msg = 'Ajout de ${controller.text}';
      }
    } else {
      msg = 'Pas de controller ?';
    }
    // Repaint list in Dropdown and report
    _updateConfiguration();
    _report(msg);
  }

  // Remove String val from Arrau col in Firebase
  Future _remove(String col, String val) async {
    CollectionReference configuration = FirebaseFirestore.instance.collection("configuration");
    var doc = await configuration.doc('0P7ZltbztNCsXLZIkDcV').get();

    String msg = '';
    List<String> list = doc.get(col).cast<String>();
    TextEditingController? controller = _getController(col);
    if (controller != null) {
      if (controller.text == '') {
        msg = 'Donnez un nom !';
      } else if (list.contains(controller.text)) {
        list.remove(controller.text);
        doc.reference.update({col: list});
        // doleances.doc(tache.uid).update({'priority': priority});
        msg = 'La liste contenait, et ne contient plus ${controller.text}';
      } else {
        msg = 'La liste ne contient pas ${controller.text}';
      }
    } else {
      msg = 'Pas de controller ?';
    }
    // Repaint list in Dropdown and report
    _updateConfiguration();
    _report(msg);
  }

  @override
  void dispose() {
    _controllerWhere.dispose();
    _controllerWhat.dispose();
    super.dispose();
  }

  // Gets controller for 'col' witch can be 'what' or 'where'
  TextEditingController? _getController(String col) {
    TextEditingController? controller;
    switch (col) {
      case 'where':
        controller = _controllerWhere;
        break;
      case 'what':
        controller = _controllerWhat;
        break;
    }
    return controller;
  }

  // Report in a Dialog
  Future<void> _report(msg) async {
    await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('$msg'),
          );
        });
  }

  // Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doléances configuration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text('Endroits possibles'),
          DropdownButton<String>(
            isExpanded: true,
            items: _whereList,
            value: _whereValue,
            onChanged: (String? value) {
              setState(() {
                _whereValue = value ?? '';
                _controllerWhere.text = value ?? '';
              });
            },
          ),
          Text('Ajout ou retrait d‘un endroit possible'),
          TextFormField(
            keyboardType: TextInputType.text,
            controller: _controllerWhere,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text('Ajouter'),
                onPressed: () {
                  _add('where', _controllerWhere.text);
                },
              ),
              Padding(padding: EdgeInsets.only(left: 20)),
              ElevatedButton(
                child: const Text('Retirer'),
                onPressed: () {
                  _remove('where', _controllerWhere.text);
                },
              ),
            ],
          ),
          Padding(padding: EdgeInsets.only(bottom: 20)),
          Text('Problèmes possibles'),
          DropdownButton<String>(
            isExpanded: true,
            items: _whatList,
            value: _whatValue,
            onChanged: (String? value) {
              setState(() {
                _whatValue = value ?? '';
                _controllerWhat.text = value ?? '';
              });
            },
          ),
          Text("Ajout ou retrait d‘un problème possible"),
          TextFormField(
            keyboardType: TextInputType.text,
            controller: _controllerWhat,
          ),
          Padding(padding: EdgeInsets.only(bottom: 20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text('Ajouter'),
                onPressed: () {
                  _add('what', _controllerWhat.text);
                },
              ),
              Padding(padding: EdgeInsets.only(left: 20)),
              ElevatedButton(
                child: const Text('Retirer'),
                onPressed: () {
                  _remove('what', _controllerWhat.text);
                },
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
