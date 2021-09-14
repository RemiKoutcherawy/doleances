import 'package:doleances/Listing.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// A Widget to add a Task
class Adding extends StatefulWidget {
  @override
  _AddingState createState() => _AddingState();
}

class _AddingState extends State<Adding> {
  // final FirebaseMessaging messaging = FirebaseMessaging.instance;
  // Dropdown list and selected value
  List<DropdownMenuItem<String>>? _whereList;
  String? _whereValue;
  List<DropdownMenuItem<String>>? _whatList;
  String? _whatValue;
  // Report message
  String _message = '';
  // Style
  static const TextStyle style = TextStyle(fontSize: 20,);
  // Controller for Comment TextFormField
  TextEditingController _controllerComment = TextEditingController();

  @override
  void initState() {
    Firebase.initializeApp().whenComplete(() {
      _fetchChoices();
      setState(() {});
    });
    super.initState();
  }

  void dispose() {
    _controllerComment.dispose();
    super.dispose();
  }

  // Fetch and sets 'what' 'where'
  Future<void> _fetchChoices() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushNamed(context, '/login');
    }
    FirebaseFirestore store = FirebaseFirestore.instance;
    CollectionReference<Map<String, dynamic>> configuration = store.collection("configuration");
    configuration.get().then((snapshot) {
      QueryDocumentSnapshot<Object?> doc = snapshot.docs[0]; // only the first doc
      List<String> listWhat = doc.get('what').cast<String>();
      List<DropdownMenuItem<String>> listWhatDropDown =
          listWhat.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style:style),
        );
      }).toList();
      _whatList = listWhatDropDown;
      _whatValue = listWhat.first; // important

      List<String> listWhere = doc.get('where').cast<String>();
      List<DropdownMenuItem<String>> listWhereDropDown =
          listWhere.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style:style),
        );
      }).toList();
      _whereList = listWhereDropDown;
      _whereValue = listWhere.first; // important
      setState(() {});
    }).catchError(_onError);
  }

  // Get values and add  to Firebase
  Future<void> _addTask() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _message = 'Erreur client non défini.';
    } else if (user.email == null) {
      _message = 'Erreur client sans mail.';
    } else {
      String _mail = user.email!; // Should not need bang operator
      if (_mail.contains('test')) {
        // TODO add to Listing._tasks
        _message = 'Ajouté en local seulement. Test n‘a pas le droit de modifier la base.';
        _report(_message);
      } else if (_mail.contains('client') || _mail.contains('gestion')) {
        CollectionReference<Map<String, dynamic>> doleances = FirebaseFirestore.instance.collection('doleances');
        doleances.add(<String, dynamic>{
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'uid': user.uid,
          'displayName': user.displayName,
          'what': _whatValue,
          'where': _whereValue,
          'comment': _controllerComment.text,
          'priority': 0,
        }).then((value) {
          _message = 'Doléance ajoutée';
          _report(_message);
          setState(() {});
        }).catchError(_onError);
      }
    }
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
            content: Text('$msg', style:style),
          );
        });
  }

  // Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doléances', style:style),
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
              title: Text('Liste', style:style,),
              onTap: () {
                Navigator.pushNamed(context, '/listing');
              },
            ),
            ListTile(
              title: Text('Ajout', style:style,),
              onTap: () {
                Navigator.pushNamed(context, '/adding');
              },
            ),
            ListTile(
              title: Text('Configuration', style:style,),
              onTap: () {
                Navigator.pushNamed(context, '/configuration');
              },
            ),
            ListTile(
              title: Text('Connexion / Déconnexion', style:style,),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
            Divider(),
            ListTile(
              title: Text('A propos', style:style,),
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
          Text("Quel est le problème ?", style:style),
          DropdownButton<String>(
            isExpanded: true,
            items: _whatList,
            value: _whatValue,
            onChanged: (String? value) async {
              setState(() {
                _whatValue = value!;
              });
            },
          ),
          Padding(padding: EdgeInsets.only(bottom: 20)),
          Text('Où se situe le problème ?', style:style),
          DropdownButton<String>(
            isExpanded: true,
            itemHeight: 50,
            items: _whereList,
            value: _whereValue,
            onChanged: (String? value) {
              setState(() {
                _whereValue = value!;
              });
            },
          ),
          Padding(padding: EdgeInsets.only(bottom: 20)),
          Text('Commentaire éventuel ?', style:style),
          TextFormField(
            maxLines: 3,
            keyboardType: TextInputType.multiline,
            controller: _controllerComment,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text('Ajouter', style:style),
                onPressed: () {
                  _addTask();
                  //Navigator.pushNamed(context, '/listing');
                },
              ),
            ],
          ),
          Text(_message, style:style,),
        ]),
      ),
    );
  }
}
