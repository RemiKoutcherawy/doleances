import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// A Widget to add a Tache
class Ajout extends StatefulWidget {
  @override
  _AjoutState createState() => _AjoutState();
}

class _AjoutState extends State<Ajout> {
  // Dropdown list and selected value
  List<DropdownMenuItem<String>>? _whereList;
  String? _whereValue;
  List<DropdownMenuItem<String>>? _whatList;
  String? _whatValue;

  // Controller for Comment TextFormField
  TextEditingController _controllerComment = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  void dispose() {
    _controllerComment.dispose();
    super.dispose();
  }

  // Fetch and sets 'what' 'where'
  Future _loadPrefs() async {
    await Firebase.initializeApp();
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushNamed(context, '/login');
    }
    FirebaseFirestore store = FirebaseFirestore.instance;
    CollectionReference<Map<String, dynamic>> configuration = store.collection("configuration");

    // TODO Try Catch
    QuerySnapshot snapshot = await configuration.get();
    QueryDocumentSnapshot<Object?> doc = snapshot.docs[0]; // only the first
    // configuration contains what[] and where[]

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

  // Get values and add  to Firebase
  Future _addTask() async {
    String uid = 'null';
    String displayName = 'null';
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user.uid;
      displayName = user.displayName ?? displayName;
    }
    await FirebaseFirestore.instance.collection('doleances').add(<String, dynamic>{
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'uid': uid,
      'displayName': displayName,
      'what': _whatValue,
      'where': _whereValue,
      'comment': _controllerComment.text,
      'priority': 0,
    });
    _report('Doléance ajoutée');
  }

  // Report in a Dialog
  void _report(msg) {
    showDialog(
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
        title: const Text('Doléances'),
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
              title: Text('Liste'),
              onTap: () {
                Navigator.pushNamed(context, '/liste');
              },
            ),
            ListTile(
              title: Text('Ajout'),
              onTap: () {
                Navigator.pushNamed(context, '/ajout');
              },
            ),
            ListTile(
              title: Text('Configuration'),
              onTap: () {
                Navigator.pushNamed(context, '/configuration');
              },
            ),
            ListTile(
              title: Text('Connexion / Déconnexion'),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
            Divider(),
            ListTile(
              title: Text('A propos'),
              onTap: () {
                Navigator.pushNamed(context, '/apropos');
              },
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text("Quel est le problème ?"),
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
          Text('Où se situe le problème ?'),
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
          Text('Commentaire éventuel ?'),
          TextFormField(
            maxLines: 3,
            keyboardType: TextInputType.multiline,
            controller: _controllerComment,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text('Ajouter'),
                onPressed: () {
                  _addTask();
                  Navigator.pushNamed(context, '/liste');
                },
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
