import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Tache.dart';
// See https://firebase.flutter.dev/docs/firestore/usage/

// List Taches in a table
class Liste extends StatefulWidget {
  Liste();
  @override
  _Liste createState() => _Liste();
}

class _Liste extends State<Liste> {
  // List of doleances to show
  List<Tache> _taches = [];

  @override
  void initState() {
    super.initState();
    _fetchDoleances();
  }

  // Fetch and fill _taches
  Future _fetchDoleances() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushNamed(context, '/login');
    }
    var doleances = FirebaseFirestore.instance.collection("doleances");
    QuerySnapshot snapshot = await doleances.get();
    List<QueryDocumentSnapshot> list = snapshot.docs;
    // TODO add try catch
    for (final d in list) {
      String uid = d.id;
      String what = d.get('what');
      String where = d.get('where');
      String comment = d.get('comment');
      int priority = int.parse(d.get('priority').toString());
      Tache tache = Tache(uid: uid, what: what, where: where, comment: comment, priority: priority);
      // Add to class field
      _taches.add(tache);
    }
    setState(() {});
  }

  // Build rows with a header
  List<TableRow> _rows() {
    var header = TableRow(
        decoration: BoxDecoration(color: Colors.blue[100],),
        children: <Widget>[
          Container(padding: EdgeInsets.all(5), child: Text("Quoi"),),
          Container(padding: EdgeInsets.all(5), child: Text("Où"),),
          Container(padding: EdgeInsets.all(5), child: Text("Commentaire"),),
          Container(padding: EdgeInsets.all(5), child: Text("Priorité"),),
        ]);
    var rows = List<TableRow>.generate(
      _taches.length,
      _cell,
    );
    return [header,...rows];
  }

  // Build cells for each row
  TableRow _cell(int index) {
    Tache tache = _taches[index];
    Color color = Colors.white;
    switch (tache.priority){
      case 0 : color = index % 2 == 0 ? Colors.grey[200]! : Colors.white; break;
      case 1 : color = Colors.orangeAccent; break;
      case -1 : color = Colors.lightGreen; break;
      default : color = Colors.white; break;
    }
    return TableRow(
      decoration: BoxDecoration(
        color: color,
      ),
      children:[
        Container(padding: EdgeInsets.all(5), child: Text(tache.what),),
        Container(padding: EdgeInsets.all(5), child: Text(tache.where),),
        Container(padding: EdgeInsets.all(5), child: Text(tache.comment),),
        GestureDetector(
            child: Container(padding: EdgeInsets.all(5), child: Text(tache.priority.toString()),),
            onTap: () {
              _setPriority(tache);
            }
        ),
      ]);
  }

  // Show a Dialog to select priority, then update priority in Firebase
  Future<void> _setPriority(Tache tache) async {
    int priority = await showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Priorité'),
            children: <Widget>[
              Column(
                children: [
                  SimpleDialogOption(
                    child: Text('Prioritaire'),
                    onPressed: () {
                      Navigator.pop(context, 1);
                    },
                  ),
                  SimpleDialogOption(
                    child: Text('Normal'),
                    onPressed: () {
                      Navigator.pop(context, 0);
                    },
                  ),
                  SimpleDialogOption(
                    child: Text('Terminé'),
                    onPressed: () {
                      Navigator.pop(context, -1);
                    },
                  ),
                  SimpleDialogOption(
                    child: Text('Supprimer la tâche'),
                    onPressed: () {
                      Navigator.pop(context, -2);
                    },
                  ),
                ],
              ),
            ],
          );
        });
    tache.priority = priority;

    setState(() {});

    // Update Firebase CollectionReference<Map<String, dynamic>>
    var doleances = FirebaseFirestore.instance.collection("doleances");
    doleances.doc(tache.uid).update({'priority': priority});
    if (priority == -2) {
      doleances.doc(tache.uid).delete();
      _taches.remove(tache);
      setState(() {});
    }
  }

  // Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doléances'),
      ),
      body: SingleChildScrollView(
        child: Table(
          border: TableBorder.all(color: Colors.black),
          columnWidths: <int, TableColumnWidth>{
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(3),
            3: FlexColumnWidth(0.5),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.top,
          children: _rows(),
        ),
      ),
    );
  }
}
