import 'package:flutter/material.dart';

void main() => runApp(const App());

// See https://stackoverflow.com/questions/56625052/how-to-make-a-multi-column-flutter-datatable-widget-span-the-full-width
class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'title',
      home: Scaffold(
        appBar: AppBar(title: const Text('title')),
        body: const MyStatelessWidget(),
      ),
    );
  }
}

/// This is the stateless widget that the main application instantiates.
class MyStatelessWidget extends StatelessWidget {
  const MyStatelessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DataTable dataTable = buildDataTable();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: dataTable,
            ),
          ),
        ),
      ),
    );
  }

  DataTable buildDataTable() {
    return DataTable(
      columnSpacing: 0,
      showBottomBorder: true,
    columns: const <DataColumn>[
      DataColumn(label: Text('Name',),),
      DataColumn(label: VerticalDivider()),
      DataColumn(label: Text('Age ',),),
      DataColumn(label: VerticalDivider()),
      DataColumn(label: Text('Role',),),
    ],
    rows: const <DataRow>[
      DataRow(
        cells: <DataCell>[
          // DataCell(Text('Sarah')),
          DataCell(Text('Sarah Sarah Sarah Sarah Sarah Sarah Sarah '),),
          DataCell(VerticalDivider()),
          DataCell(Text('19 ')),
          // DataCell(Text('19 19 19 19 19 19 19 19 19 19 19 19 19 19 '),),
          DataCell(VerticalDivider(),),
          DataCell(Text('Student')),
        ],
      ),
      DataRow(
        cells: <DataCell>[
          DataCell(Text('Janine')),
          DataCell(VerticalDivider()),
          DataCell(Text('43')),
          DataCell(VerticalDivider()),
          DataCell(Text('Professor')),
        ],
      ),
      DataRow(
        cells: <DataCell>[
          DataCell(Text('William')),
          DataCell(VerticalDivider()),
          DataCell(Text('27')),
          DataCell(VerticalDivider()),
          DataCell(Text('Professor ')),
        ],
      ),
    ],
  );
  }
}

