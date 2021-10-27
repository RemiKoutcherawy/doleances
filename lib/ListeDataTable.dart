import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:doleances/Doleances.dart';
import 'package:doleances/Task.dart';

class ListeDataTable extends StatefulWidget {
  const ListeDataTable({Key? key}) : super(key: key);

  @override
  _ListeDataTable createState() => _ListeDataTable();
}

class _ListeDataTable extends State<ListeDataTable> {
  // Classe instance of Doleances
  // Will be replaced by doleances = context.watch<Doleances>();
  Doleances doleances = Doleances();

  // Build header
  List<DataColumn> _columns() {
    return <DataColumn>[
      DataColumn(label: Text('Quoi'),),
      DataColumn(label: VerticalDivider()),
      DataColumn(label: Text('Où'),),
      DataColumn(label: VerticalDivider()),
      DataColumn(label: Text('Commentaire'),),
      DataColumn(label: VerticalDivider()),
      DataColumn(label: Text('Priorité'),),
      // DataColumn(label: VerticalDivider()),
    ];
  }

  // Build rows
  List<DataRow> _rows(doleances) {
    return List<DataRow>.generate(
      doleances.tasks.length,
      _rowCells,
    );
  }

  // Build cells
  DataRow _rowCells(int index) {
    Task task = doleances.tasks[index];
    Color color = Colors.white;
    switch (task.priority){
      case 0 : color = index % 2 == 0 ? Colors.grey[200]! : Colors.white; break;
      case 1 : color = Colors.orangeAccent; break;
      case -1 : color = Colors.lightGreen; break;
      default : color = index.isEven ? Colors.white: Colors.grey.withOpacity(0.2) ; break;
    }
    return DataRow(
        cells: <DataCell>[
          DataCell(Text(task.what,),),
          DataCell(VerticalDivider(),),
          DataCell(Text(task.where),),
          DataCell(VerticalDivider(),),
          DataCell(Text(task.comment,),),
          DataCell(VerticalDivider(),),
          DataCell(Text(task.priority.toString(),),),
        ],
        color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) => color),
        onSelectChanged: (bool? value) {
          // Let 200s to correct a new task
          if (!doleances.gestion()
              && (DateTime.now().millisecondsSinceEpoch - task.timestamp > 200000)
          ) {
            _report('Les clients n‘ont pas le droit de modifier la liste');
            setState(() {});
          } else {
            _setPriority(task);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    // Provider
    doleances = context.watch<Doleances>();
    String? notification = doleances.notification;
    if (notification != null && mounted) {
      showSnackBar(notification);
      doleances.notification = null;
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: buildDataTable(),
                ),
              ),
          ),
        ),
    );
  }
  DataTable buildDataTable(){
    return DataTable(
      columnSpacing: 0,
      sortAscending: false,
      showCheckboxColumn: false,
      showBottomBorder: true,
      // Content
      columns: _columns(),
      rows: _rows(doleances),
    );
  }

  // Show a Dialog to select priority, then update priority in Firebase
  Future<void> _setPriority(Task task) async {
    int? priority = await _askForPriority(task);
    if (priority != null && priority != task.priority) {
      task.priority = priority;
      if (priority == -2) {
      doleances.tasks.remove(task);
      }
      setState(() {});
      doleances.setPriority(task);
    }
  }

  // Ask for priority in a Dialog
  Future<dynamic> _askForPriority(Task task) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('${task.what} / ${task.where}',),
            children: <Widget>[
              Column(
                children: [
                  Text('${task.comment}',
                    style: TextStyle(fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                  SimpleDialogOption(
                    child: Text('Prioritaire',),
                    onPressed: () {
                      Navigator.pop(context, 1);
                    },
                  ),
                  SimpleDialogOption(
                    child: Text('Normal',),
                    onPressed: () {
                      Navigator.pop(context, 0);
                    },
                  ),
                  SimpleDialogOption(
                    child: Text('Terminé',),
                    onPressed: () {
                      Navigator.pop(context, -1);
                    },
                  ),
                  SimpleDialogOption(
                    child: Text('Supprimer la tâche',),
                    onPressed: () {
                      Navigator.pop(context, -2);
                    },
                  ),
                  SimpleDialogOption(
                    child: Text('Annuler',),
                    onPressed: () {
                      Navigator.pop(context, task.priority);
                    },
                  ),
                ],
              ),
            ],
          );
        });
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

  // Notification in a SnackBar
  Future<void> showSnackBar(String msg) async {
    await Future.delayed(Duration(seconds: 1));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6,
      ),
      duration: Duration(seconds: 3),
      backgroundColor: Colors.lightBlueAccent,
    ));
  }
}
