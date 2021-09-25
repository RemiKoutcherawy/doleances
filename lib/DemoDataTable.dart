import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DataTableDemo(),
    );
  }
}
class DataTableDemo extends StatefulWidget {
  DataTableDemo() : super();
  final String title = "Data Table";

  @override
  DataTableDemoState createState() => DataTableDemoState();
}

class DataTableDemoState extends State<DataTableDemo> {
  List<Customer>? users;
  List<Customer>? selectedUsers;
  bool? sort;
  TextEditingController? _controller;
  int iSortColumnIndex = 0;
  int iContact = 0;

  @override
  void initState() {
    sort = false;
    selectedUsers = [];
    users = Customer.getUsers();


    _controller = new TextEditingController();

    super.initState();
  }

  onSortColum(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      if (ascending) {
        users!.sort((a, b) => a.firstName.compareTo(b.firstName));
      } else {
        users!.sort((a, b) => b.firstName.compareTo(a.firstName));
      }
    }
  }

  onSelectedRow(bool selected, Customer user) async {
    setState(() {
      if (selected) {
        selectedUsers!.add(user);
      } else {
        selectedUsers!.remove(user);
      }
    });
  }

  deleteSelected() async {
    setState(() {
      if (selectedUsers!.isNotEmpty) {
        List<Customer> temp = [];
        temp.addAll(selectedUsers!);
        for (Customer user in temp) {
          users!.remove(user);
          selectedUsers!.remove(user);
        }
      }
    });
  }

  SingleChildScrollView dataBody() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints.expand(width: MediaQuery.of(context).size.width),
        child: DataTable(
          sortAscending: sort!,
          sortColumnIndex: iSortColumnIndex,
          columns: [
            DataColumn(
                label: Text("FIRST NAME"),
                numeric: false,
                tooltip: "This is First Name",
                onSort: (columnIndex, ascending) {
                  setState(() {
                    sort = !sort!;
                  });
                  onSortColum(columnIndex, ascending);
                }),
            DataColumn(
              label: Text("LAST NAME"),
              numeric: false,
              tooltip: "This is Last Name",
            ),
            DataColumn(label: Text("CONTACT NO"), numeric: false, tooltip: "This is Contact No")
          ],
          columnSpacing: 2,
          rows: users!
              .map(
                (user) => DataRow(
                selected: selectedUsers!.contains(user),
                onSelectChanged: (b) {
                  print("Onselect");
                  onSelectedRow(b!, user);
                },
                cells: [
                  DataCell(
                    Text(user.firstName),
                    onTap: () {
                      print('Selected ${user.firstName}');
                    },
                  ),
                  DataCell(
                    Text(user.lastName),
                  ),
                  DataCell(Text("${user.iContactNo}"),
                      showEditIcon: true, onTap: () => showEditDialog(user))
                ]),
          )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
//          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            Expanded(
              child: Container(
                child: dataBody(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: OutlinedButton(
                    child: Text('SELECTED ${selectedUsers!.length}'),
                    onPressed: () {},
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: OutlinedButton(
                    child: Text('DELETE SELECTED'),
                    onPressed: selectedUsers!.isEmpty ? null : () => deleteSelected(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showEditDialog(Customer user) {
    String sPreviousText = user.iContactNo.toString();
    String sCurrentText = '';
    _controller!.text = sPreviousText;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Edit Contact No"),
          content: new TextFormField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Enter an Contact No'),
            onChanged: (input) {
              if (input.length > 0) {
                sCurrentText = input;
                iContact = int.parse(input);
              }
            },
          ),
          actions: <Widget>[
            new TextButton(
              child: new Text("Save"),
              onPressed: () {
                setState(() {
                  if (sCurrentText.length > 0) user.iContactNo = iContact;
                });
                Navigator.of(context).pop();
              },
            ),
            new TextButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
class Customer {
  String firstName;
  String lastName;
  int iContactNo;

  Customer({this.firstName='', this.lastName='',this.iContactNo=0});

  static List<Customer> getUsers() {
    return <Customer>[
      Customer(firstName: "Aaryan", lastName: "Shah",iContactNo: 123456897),
      Customer(firstName: "Ben", lastName: "John",iContactNo: 78879546),
      Customer(firstName: "Carrie", lastName: "Brown",iContactNo: 7895687),
      Customer(firstName: "Deep", lastName: "Sen",iContactNo: 123564),
      Customer(firstName: "Emily", lastName: "Jane", iContactNo: 5454698756),
    ];
  }
}