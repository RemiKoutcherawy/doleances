import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Task.dart';
// See https://firebase.flutter.dev/docs/firestore/usage/

// List Tasks in a table
class Listing extends StatefulWidget {
  Listing();
  @override
  _Listing createState() => _Listing();
}

class _Listing extends State<Listing> {
  // List of doleances
  List<Task> _tasks = [];
  // Report message
  String _message = 'message';

  @override
  void initState() {
    Firebase.initializeApp().whenComplete(() {
      _fetchDoleances();
      setState(() {});
    });
    super.initState();
  }

  // Fetch and fill tasks
  Future<void> _fetchDoleances() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushNamed(context, '/login');
    }
    CollectionReference<Map<String, dynamic>> doleances = FirebaseFirestore.instance.collection("doleances");
    doleances.get().then((QuerySnapshot<Map<String, dynamic>> snapshot) {
      List<QueryDocumentSnapshot> list = snapshot.docs;
      for (final d in list) {
        String uid = d.id;
        String what = d.get('what');
        String where = d.get('where');
        String comment = d.get('comment');
        int priority = int.parse(d.get('priority').toString());
        Task task = Task(uid: uid, what: what, where: where, comment: comment, priority: priority);
        // Add to class field tasks
        _tasks.add(task);
      }
      setState(() {});
    }).catchError(_onError);
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
      _tasks.length,
      _rowCells,
    );
    return [header,...rows];
  }

  // Build cells for each row
  TableRow _rowCells(int index) {
    Task task = _tasks[index];
    Color color = Colors.white;
    switch (task.priority){
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
        Container(padding: EdgeInsets.all(5), child: Text(task.what),),
        Container(padding: EdgeInsets.all(5), child: Text(task.where),),
        InkWell(
          child: Container(padding: EdgeInsets.all(5), child: Text(task.comment),),
          onTap: () {_setPriority(task);},
        ),
        Container(padding: EdgeInsets.all(5), child: Text(task.priority.toString()),),
      ]);
  }

  // Show a Dialog to select priority, then update priority in Firebase
  Future<void> _setPriority(Task task) async {
    int priority = await _askForPriority();
    task.priority = priority;

    // Update local listing
    if (priority == -2) {
      _tasks.remove(task);
    }

    User? user = FirebaseAuth.instance.currentUser;
    String _mail = 'mail';
    if (user == null) {
      _message = 'Erreur client non défini.';
    } else if (user.email == null) {
      _message = 'Erreur client sans mail.';
    } else {
      _mail = user.email!;
      if (_mail.contains('test') || _mail.contains('client')) {
        _message =
            'Modifié en local seulement. Les clients n‘ont pas le droit de changer la priorité.';
        _report(_message);
      } else if (_mail.contains('gestion')) {
        // Update Firebase CollectionReference<Map<String, dynamic>> doleances
        CollectionReference<Map<String, dynamic>> doleances = FirebaseFirestore.instance.collection("doleances");
        await doleances.doc(task.uid).update({'priority': priority}).catchError(_onError);
        if (priority == -2) {
          doleances.doc(task.uid).delete().catchError(_onError);
        }
      }
    }
    setState(() {});
  }

  // Ask for priority in a Dialog
  Future<dynamic> _askForPriority() {
    return showDialog(
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
      persistentFooterButtons: [
        Center(child: Text(_message, style: TextStyle(fontSize: 20,),),),
      ],
    );
  }
}
