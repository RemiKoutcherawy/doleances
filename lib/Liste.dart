import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:doleances/Doleances.dart';
import 'package:doleances/Task.dart';

// List Tasks in a table
class Liste extends StatefulWidget {
  @override
  _ListeState createState() => _ListeState();
}

class _ListeState extends State<Liste> {
  // Local cache
  List<Task> _tasks = [Task()];
  TextStyle? _style5;
  TextStyle? _style6;
  Doleances? doleances;

  // Build rows with a header
  List<TableRow> _rows() {
    var header = TableRow(
        decoration: BoxDecoration(color: Colors.blue[100],),
        children: <Widget>[
          Container(padding: EdgeInsets.all(5), child: Text("Quoi",style:_style6),),
          Container(padding: EdgeInsets.all(5), child: Text("Où",style:_style6,),),
          Container(padding: EdgeInsets.all(5), child: Text("Commentaire",style:_style6,),),
          Container(padding: EdgeInsets.all(5), child: Text("Pr.",style:_style6,),),
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
        Container(padding: EdgeInsets.all(5), child: Text(task.what,style:_style6,),),
        Container(padding: EdgeInsets.all(5), child: Text(task.where,style:_style6,),),
        InkWell(
          child: Container(padding: EdgeInsets.all(5), child: Text(task.comment,style:_style6,),),
            onTap: () {
              if (!doleances!.gestion()) {
                _report('Les clients n‘ont pas le droit de modifier la liste');
              } else {
                _setPriority(task);
              }
            },
        ),
        Container(padding: EdgeInsets.all(5), child: Text(task.priority.toString(),style:_style6,),),
      ]);
  }

  // Show a Dialog to select priority, then update priority in Firebase
  Future<void> _setPriority(Task task) async {
    int? priority = await _askForPriority(task);
    if (priority != null && priority != task.priority) {
      task.priority = priority;
      // Update local listing
      if (priority == -2) {
        _tasks.remove(task);
      }
      // Redraw
      setState(() {});
      // Update Firebase
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
          title: Text('${task.what} / ${task.where}',style:_style5,),
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

  // Widget
  @override
  Widget build(BuildContext context) {
    // Provider
    doleances = context.watch<Doleances>();
    _tasks = doleances!.tasks;
    // Styles
    _style5 = Theme.of(context).textTheme.headline5;
    _style6 = Theme.of(context).textTheme.headline6;

    // Widget
    return Scaffold(
      appBar: AppBar(
        title: Text('Doléances',style:_style6,),
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
      // persistentFooterButtons: [
      //   Center(child: Text(doleances!.message,style:_style6,),),
      // ],
    );
  }
}
