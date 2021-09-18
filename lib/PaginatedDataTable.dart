// main.dart
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Doléances',
        theme: ThemeData(
          primarySwatch: Colors.pink,
        ),
        home: ListScreen());
  }
}

class ListScreen extends StatefulWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  DataTableSource _data = MyData();

  Future<void> _setPriority(int index) async {
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

    // Update Firebase CollectionReference<Map<String, dynamic>>
    // var doleances = FirebaseFirestore.instance.collection("doleances");
    // doleances.doc(tache.uid).update({'priority': priority});
    // if (priority == -2) {
    //   doleances.doc(tache.uid).delete();
    //   _taches.remove(tache);
    // }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PaginatedDataTable'),
      ),
      body:  Column(
          children: [SizedBox(height: 10,),
            PaginatedDataTable(
              source: _data,
              // header: Text('Doléances'),
                // actions : [
                //   ElevatedButton(child:Text('Quoi'), onPressed: (){print ('press');},),
                //   ElevatedButton(child:Text('Ou'), onPressed: (){print ('press');},),
                //   ElevatedButton(child:Text('Commentaire'), onPressed: (){print ('press');},),
                // ],
              columns: [
                DataColumn(label: Text('Quoi')),
                DataColumn(label: Text('Ou')),
                DataColumn(label: Text('Commentaire')),
              ],
              columnSpacing: 100,
              horizontalMargin: 10,
              rowsPerPage: 8,
              showCheckboxColumn: false,
            ),
          ],
        ),
    );
  }
}

// The data for the table
class MyData extends DataTableSource {
  MyData();
  // 200 entrées
  List<Map<String, dynamic>> _data = List.generate(
      200,
      (index) => {
        'what': 'Quoi $index',
        'where': 'Ou $index',
        'comment': 'Commentaire texte sur $index texte texte texte texte',
        'priority': 2 - Random().nextInt(4),
        });

  bool get isRowCountApproximate => false;
  int get rowCount => _data.length;
  int get selectedRowCount => 0;

  MaterialStateProperty<Color> rowColor(index, priority){
    Color color = Colors.white;
    switch (priority){
      case 0 : color = index % 2 == 0 ? Colors.grey[200]! : Colors.white; break;
      case 1 : color = Colors.orangeAccent; break;
      case -1 : color = Colors.lightGreen; break;
      default : color = Colors.white; break;
    }
    var all = MaterialStateProperty.all(color);
    return all;
  }

  DataRow getRow(int index) {
    return DataRow(
      onSelectChanged: (b) => {
        // print('onSelectChanged $index $b');
      },
        color: rowColor(index, _data[index]["priority"]),
    cells: [
      DataCell(Text(_data[index]["what"])),
      DataCell(Text(_data[index]["where"])),
      DataCell(Text(_data[index]["comment"])),
      // DataCell(Text(_data[index]["priority"].toString())),
    ]);
  }

}
