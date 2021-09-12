import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// See https://firebase.flutter.dev/docs/firestore/usage/

// Configure choices presented in Adding.dart
class Configuration extends StatefulWidget {
  @override
  _ConfigurationState createState() => _ConfigurationState();
}

class _ConfigurationState extends State<Configuration> {
  // Dropdown list and selected value
  List<DropdownMenuItem<String>>? _whatList;
  String? _whatValue;
  List<DropdownMenuItem<String>>? _whereList;
  String? _whereValue;

  // Report message
  String _message = '';

  // Controllers for TextFormFields
  final _controllerWhere = TextEditingController();
  final _controllerWhat = TextEditingController();

  @override
  void initState() {
    Firebase.initializeApp().whenComplete(() {
      _fetchWhatAndWhere();
      setState(() {});
    });
    super.initState();
  }

  // Fetch values for DropDowns
  Future _fetchWhatAndWhere() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushNamed(context, '/login');
    }
    CollectionReference<Map<String, dynamic>> configuration = FirebaseFirestore.instance.collection("configuration");
    configuration.doc('0P7ZltbztNCsXLZIkDcV').get().then((DocumentSnapshot<Map<String, dynamic>> doc) {
      // doc contains what[] and where[]
      List<String> listWhat = doc.get('what').cast<String>();
      _setDropdownValues(listWhat, 'what');
      List<String> listWhere = doc.get('where').cast<String>();
      _setDropdownValues(listWhere, 'where');
      setState(() {});
    }).catchError(_onError);
  }

  // Set values in dropdown, and the selected value with first in list
  void _setDropdownValues(List<String> values, String col) {
    List<DropdownMenuItem<String>> listDropDown =
    values.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
    if (col == 'what') {
      _whatList = listDropDown;
      _whatValue = values.first; // important
    } if (col == 'where') {
      _whereList = listDropDown;
      _whereValue = values.first; // important
    }
  }

  // Add String val to Arrau col in Firebase
  Future _add(String col, String val) async {
    // col can be 'what' or 'where'
    List<DropdownMenuItem<String>>? listDropDown = (col == 'what') ? _whatList : (col == 'where') ? _whereList : _whatList;
    // Retrieve values from dropdown, guess there is a smarter way...
    List<String> list = [];
    listDropDown!.forEach((DropdownMenuItem<String> item){
      list.add(item.value!);
    });
    // Retrieve text and add to list
    TextEditingController controller = _getController(col);
    if (controller.text == '') {
      _message = 'Donnez un nom !';
      _report(_message);
      return;
    } else if (list.contains(controller.text)) {
      _message = 'La liste contient déjà ${controller.text}';
      _report(_message);
      return;
    } else {
      list.add(controller.text);
    }
    // Update dropdown with local list
    _setDropdownValues(list, col);
    setState(() {});

    // Firebase update
    CollectionReference<Map<String, dynamic>> configuration =
        FirebaseFirestore.instance.collection("configuration");
    configuration
        .doc('0P7ZltbztNCsXLZIkDcV')
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> doc) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _message = 'Erreur client non défini.';
      } else if (user.email == null) {
        _message = 'Erreur client sans mail.';
      } else {
        String _mail = user.email!;
        if (_mail.contains('test') || _mail.contains('client')) {
          _message = 'Ajouté en local seulement. Test et client n‘ont pas le droit de modifier la configuration.';
          _report(_message);
        } else if (_mail.contains('gestion')) {
          doc.reference.update({col: list});
          // Replace by remote values ?
          // list = doc.get(col).cast<String>();
          // _setDropdownValues(list, col);
          _report(_message);
        } else {
          _message = 'Ajouté en local seulement, vous n‘avez pas le droit de modifier la configuration.';
          _report(_message);
        }
      }
    }).catchError(_onError);
  }

  // Remove String val from Arrau col in Firebase
  Future _remove(String col, String val) async {
    List<DropdownMenuItem<String>>? listDropDown = (col == 'what') ? _whatList : (col == 'where') ? _whereList : _whatList;
    // Retrieve values from dropdown, guess there is a smarter way...
    List<String> list = [];
    listDropDown!.forEach((DropdownMenuItem<String> item){
      list.add(item.value!);
    });
    TextEditingController? controller = _getController(col);
    if (controller.text == '') {
      _message = 'Donnez un nom !';
      _report(_message);
      return;
    } else if (!list.contains(controller.text)) {
      _message = 'La liste ne contient pas ${controller.text}';
      _report(_message);
      return;
    } else {
      list.remove(controller.text);
      _message = 'La liste contenait, et ne contient plus ${controller.text}';
    }
    // Update dropdown with local list
    _setDropdownValues(list, col);
    setState(() {});

    // Firebase update
    CollectionReference<Map<String, dynamic>> configuration =
    FirebaseFirestore.instance.collection("configuration");
    configuration
        .doc('0P7ZltbztNCsXLZIkDcV')
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> doc) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _message = 'Erreur client non défini.';
      } else if (user.email == null) {
        _message = 'Erreur client sans mail.';
      } else {
        String _mail = user.email!; // bang operator (!) should not be required
        if (_mail.contains('test') || _mail.contains('client')) {
          _message = 'Retrait en local seulement. Test et client n‘ont pas le droit de modifier la configuration.';
          _report(_message);
        } else if (_mail.contains('gestion')) {
          // Update Firebase
          doc.reference.update({col: list});
          // Replace by remote values ?
          // list = doc.get(col).cast<String>(); // Read remote
          // _setDropdownValues(list, col); // Update dropdown
          _report(_message);
        } else {
          _message = 'Utilisateur inconnu : $_mail';
          _report(_message);
        }
      }
    }).catchError(_onError);
  }

  @override
  void dispose() {
    _controllerWhere.dispose();
    _controllerWhat.dispose();
    super.dispose();
  }

  // Gets controller for 'col' witch can be 'what' or 'where'
  TextEditingController _getController(String col) {
    TextEditingController controller = _controllerWhat; // Default
    switch (col) {
      case 'what':
        controller = _controllerWhat;
        break;
      case 'where':
        controller = _controllerWhere;
        break;
    }
    return controller;
  }

  // Catch errors and report
  _onError(e){
    _message = 'Erreur ${(e as dynamic).message}';
    _report(_message);
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
