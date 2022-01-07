import 'dart:async';

import 'package:flutter/material.dart';
import 'package:timetracker/tree.dart' as Tree hide getTree;
import 'package:timetracker/requests.dart' as requests;

import 'activity_screen.dart';

class PageIntervals extends StatefulWidget {
  final int id;

  PageIntervals(this.id);

  @override
  _PageIntervalsState createState() => _PageIntervalsState();
}

class _PageIntervalsState extends State<PageIntervals> {
  late int id;
  late Future<Tree.Tree> futureTree;
  late Timer _timer;
  static const int periodeRefresh = 2;

  @override
  void initState() {
    super.initState();
    id = widget.id;
    futureTree = requests.getTree(id);
    setState(() {});
    _activateTimer();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Tree.Tree>(
      future: futureTree,
      // this makes the tree of children, when available, go into snapshot.data
      builder: (context, snapshot) {
        // anonymous function
        if (snapshot.hasData) {
          int numChildren = snapshot.data!.root.children.length;
          return Scaffold(
            appBar: AppBar(
              title: Text('Intervalos de ' +snapshot.data!.root.name),
              actions: <Widget>[
                IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  while (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  ActivityScreen(0);
                },
              ),
              ],
            ),
            body: ListView.separated(
              // it's like ListView.builder() but better because it includes a separator between items
              padding: const EdgeInsets.all(16.0),
              itemCount: numChildren,
              itemBuilder: (BuildContext context, int index) =>
                      _buildRow(snapshot.data!.root.children[index], index),
              separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // By default, show a progress indicator
        return Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: Center(
                  child: CircularProgressIndicator(),
                ));
      },
    );
  }

  Widget _buildRow(Tree.Interval interval, int index) {
    String strDuration = Duration(seconds: interval.duration)
        .toString()
        .split('.')
        .first;
    String strInitialDate = interval.initialDate.toString().split('.')[0];
    // this removes the microseconds part
    String strFinalDate = interval.finalDate.toString().split('.')[0];

    if (interval.active) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.lightBlue[200],
          boxShadow: [BoxShadow(
            color: Colors.lightBlueAccent, spreadRadius: 5
          )]
        ),
        child: Center(
          child: Column(
            children: <Widget>[
              Text('Intérvalo activo'),
              Divider(),
              ListTile(
                title: Text('''Inicio: ${strInitialDate}
                '''),
                trailing: Text('Tiempo\n $strDuration'),
              ),
              Divider(),
            ]
          ),
        ),
      ); 
    }
    return ListTile(
      title: Text('Inicio: ${strInitialDate} Final: ${strFinalDate}'),
      trailing: Text('Tiempo\n $strDuration'),
    );
  }


  void _refresh() async {
    this.futureTree = requests.getTree(id);
    setState((){});
  }

    void _activateTimer() {
    _timer = Timer.periodic(Duration(seconds: periodeRefresh), (Timer t) {
      _refresh();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

}