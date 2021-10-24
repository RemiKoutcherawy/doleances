import 'package:flutter/material.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    _tabController = new TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Container(
            //   height: MediaQuery.of(context).size.height / 2,
            //   child: Center(
            //     child: Text(
            //       "Tabbar without Appbar",
            //       style: TextStyle(
            //           color: Colors.white, fontWeight: FontWeight.bold),
            //     ),
            //   ),
            //   color: Colors.blue,
            // ),
            TabBar(
              unselectedLabelColor: Colors.black,
              labelColor: Colors.red,
              tabs: [
                Tab(text: '1st tab',),
                Tab(text: '2nd tab',)
              ],
              controller: _tabController,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Container(child: Center(child: Text('People'))),
                  Text('Person')
                ],
                controller: _tabController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}