import 'dart:async';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:timetracker/add_activity.dart';
import 'package:timetracker/tutorial/page_activities.dart';
import 'package:timetracker/tree.dart' hide getTree;
import 'package:timetracker/requests.dart' as requests;


class ActivityScreen extends StatefulWidget {
  final int id;

  ActivityScreen(this.id);

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> with SingleTickerProviderStateMixin{
  late Future<Tree> _futuresOfActivity;
  late List<Task> _taskList = [];
  late List<Project> _projectList = [];
  late int id;
  late Timer _timer;
  static const int periodeRefresh = 2;
  late String name = '';

  @override
  void initState() {
    super.initState();
    id = widget.id;
    (_futuresOfActivity = requests.getTree(id)).then((node) {
      name = node.root.name;
      for (var activity in node.root.children) {
        //print("Entrado con " + activity.toString());
        if (activity is Task) {
          _taskList.add(activity);
        } else if (activity is Project) {
          _projectList.add(activity);
        }
      }

      //print("Tengo " + _taskList.length.toString() + " tareas");
      //print("Tengo " + _projectList.length.toString() + " proyectos");
    });

    _futuresOfActivity = requests.getTree(id);
    //print(_taskList.length);
    //print(_projectList.length);
    setState(() {});
    _activateTimer();

  }


  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
      child: FutureBuilder(
      future: _futuresOfActivity,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: (name == 'root') ?
              Text('TimeTracker App') :
              Text(name),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {},
                // ON PRESSED: Pop until!
              ),
              IconButton(

                icon: Icon(Icons.info),
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('abc'),
                    );
                  }
                ),
                // ON PRESSED: MOSTRAR INFORMACION DEL PROYECTO!
              ),
            ],
            bottom: TabBar(
              tabs: [
                Tab(
                  text: "Projects",
                  icon: Icon(Icons.folder_open),
                ),
                Tab(
                  text: "Tasks",
                  icon: Icon(IconData(0xf429, fontFamily: 'MaterialIcons')),
                )
              ],
            ),
          ),

          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => _navigateAcitityAdd(id), // MANDAR A PANTALLA DE AÑADIR 
          ),
          body: TabBarView(
            children: <Widget>[
              //Projects
              ListView.separated(
                itemCount: _projectList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_projectList[index].name),
                    onTap: () => _navigateDownActivities(_projectList[index].id),
                  );
                },
                separatorBuilder: (c,i) {
                  return Divider();
                },
              ),
              ListView.separated(
                itemCount: _taskList.length,
                itemBuilder: (context, index) {
                  String strDuration  = Duration(seconds: _taskList[index].duration).toString().split('.').first;
                  return ListTile(
                    title: Text(_taskList[index].name),
                    subtitle: Text(strDuration),
                    trailing: Switch(
                      value: _taskList[index].active,
                      activeColor: Colors.green,
                      onChanged: (change) {
                        if (_taskList[index].active) {
                          requests.stop(_taskList[index].id);
                        } else {
                          requests.start(_taskList[index].id);
                        }
                        _taskList[index].active = !_taskList[index].active;
                        _refresh();
                      },
                    ),
                    //Añadir onlongpress tal vez?
                  );
                },
                separatorBuilder: (c,i) => Divider(),
              ),
            ],
          ),
        );
      },
    ),
    );
  }

  void _refresh() async {

    _taskList.clear();
    _projectList.clear();
    
    await (_futuresOfActivity = requests.getTree(id)).then((node) {
      name = node.root.name;
      for (var activity in node.root.children) {
        //print("Entrado con " + activity.toString());
        if (activity is Task) {
          _taskList.add(activity);
        } else if (activity is Project) {
          _projectList.add(activity);
        }
      }
    });

    setState(() {});
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

  void _navigateDownActivities(int childId) {
    _timer.cancel();
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => ActivityScreen(childId),
    ));
    _activateTimer();
    _refresh();
  }

  Widget _buildInfoPopup(BuildContext context) {
    return new AlertDialog(
      title: const Text('Popup example'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("a"),
          Text("b"),
        ],
      ),
    );
  }

  void _navigateAcitityAdd(int idProject) {
    Navigator.of(context)
      .push(MaterialPageRoute<void>(
    builder: (context) => AddActivity(idProject),
  ));
  }
}