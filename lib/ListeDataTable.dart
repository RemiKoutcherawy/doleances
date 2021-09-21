import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:doleances/Doleances.dart';
import 'package:doleances/Task.dart';

// See https://api.flutter.dev/flutter/material/DataTable-class.html
// And https://stackoverflow.com/questions/65312609/flutter-datatable-how-set-column-width

class ListeDataTable extends StatefulWidget {
  const ListeDataTable({Key? key}) : super(key: key);
  @override
  _ListeDataTable createState() => _ListeDataTable();
}

class _ListeDataTable extends State<ListeDataTable> {
  // Local cache
  List<Task> _tasks = [Task()];
  Doleances? doleances;
  TextStyle? _style5;
  TextStyle? _style6;

  // Build header
  // Width .2, .2 .5 .1 sum to 1.0
  List<DataColumn> _columns(double width) {
    return <DataColumn>[
      DataColumn(label: Container(width: width * .2,child: Text('Quoi',style: _style5,),),),
      DataColumn(label: Container(width: width * .2,child: Text('Où',style: _style5),),),
      DataColumn(label: Container(width: width * .5,child: Text('Commentaire',style: _style5),),),
      DataColumn(label: Container(width: width * .1,child: Text('Pr.',style: _style5),),),
    ];
  }

  // Build rows
  List<DataRow> _rows() {
    return List<DataRow>.generate(
      _tasks.length,
      _rowCells,
    );
  }

  // Build cells
  DataRow _rowCells(int index) {
    Task task = _tasks[index];
    Color color = Colors.white;
    switch (task.priority){
      case 0 : color = index % 2 == 0 ? Colors.grey[200]! : Colors.white; break;
      case 1 : color = Colors.orangeAccent; break;
      case -1 : color = Colors.lightGreen; break;
      default : color = index.isEven ? Colors.white: Colors.grey.withOpacity(0.2) ; break;
    }
    return DataRow(
        cells: <DataCell>[
          DataCell(Text(task.what, style:_style6,)),
          DataCell(Text(task.where, style:_style6,)),
          DataCell(Text(task.comment, style:_style6,)),
          DataCell(Text(task.priority.toString(), style:_style6,)),
        ],
        color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) => color),
        onSelectChanged: (bool? value) {
          if (!doleances!.gestion()) {
            print ('Les clients n‘ont pas le droit de modifier la liste');
            _report('Les clients n‘ont pas le droit de modifier la liste');
            setState(() {});
          } else {
            print ('_setPriority');
            _setPriority(task);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    // Provider
    doleances = context.watch<Doleances>();
    _tasks = doleances!.tasks;
    // Styles
    _style5 = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
    _style6 = Theme.of(context).textTheme.headline6;
    // To set Width .2, .2 .5 .1 sum to 1.0
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          title: Text('ListDataTable', style: _style5,),),
        body: Theme(
            data: Theme.of(context).copyWith(
              dividerTheme: DividerThemeData(
                color: Colors.black,
                thickness: 10, // Bug not taken
              ),
            ),
            child: DataTable(
              columnSpacing: 0,
              sortAscending: false,
              showCheckboxColumn: false,
              showBottomBorder: true,
              dividerThickness: 2, // Taken
              // Heading
              decoration: BoxDecoration(color: Colors.blue[100],),
              headingTextStyle:TextStyle(fontStyle: FontStyle.italic, color: Colors.black),
              // Content
              columns: _columns(width),
              rows: _rows(),
            )));
  }

  // Show a Dialog to select priority, then update priority in Firebase
  Future<void> _setPriority(Task task) async {
    int? priority = await _askForPriority(task);
    if (priority != null && priority != task.priority) {
      task.priority = priority;
      if (priority == -2) {
        _tasks.remove(task);
      }
      setState(() {});
      doleances?.setPriority(task);
    }
  }

  // Ask for priority in a Dialog
  Future<dynamic> _askForPriority(Task task) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('${task.what} / ${task.where}', style:_style5,),
            children: <Widget>[
              Column(
                children: [
                  SimpleDialogOption(
                    child: Text('Prioritaire',style:_style6,),
                    onPressed: () {
                      Navigator.pop(context, 1);
                    },
                  ),
                  SimpleDialogOption(
                    child: Text('Normal',style:_style6,),
                    onPressed: () {
                      Navigator.pop(context, 0);
                    },
                  ),
                  SimpleDialogOption(
                    child: Text('Terminé',style:_style6,),
                    onPressed: () {
                      Navigator.pop(context, -1);
                    },
                  ),
                  SimpleDialogOption(
                    child: Text('Supprimer la tâche',style:_style6,),
                    onPressed: () {
                      Navigator.pop(context, -2);
                    },
                  ),
                  SimpleDialogOption(
                    child: Text('Annuler',style:_style6,),
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
            content: Text('$msg', style: _style5,),
          );
        });
  }
}
