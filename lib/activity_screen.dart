import 'dart:async';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:timetracker/add_activity.dart';
import 'package:timetracker/tutorial/page_activities.dart';
import 'package:timetracker/tree.dart' as Tree hide getTree;
import 'package:timetracker/requests.dart' as requests;
import 'package:timetracker/intervals_screen.dart';

class ActivityScreen extends StatefulWidget {
  final int id;

  ActivityScreen(this.id);

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> with SingleTickerProviderStateMixin{
  late Future<Tree.Tree> _futuresOfActivity;
  late List<Tree.Task> _taskList = [];
  late List<Tree.Project> _projectList = [];
  late int id;
  late Timer _timer;
  static const int periodeRefresh = 2;
  late String name = '';
  late StateSetter _stateSetter;
  
  @override
  void initState() {
    super.initState();
    id = widget.id;
    (_futuresOfActivity = requests.getTree(id)).then((node) {
      name = node.root.name;
      for (var activity in node.root.children) {
        //print("Entrado con " + activity.toString());
        if (activity is Tree.Task) {
          _taskList.add(activity);
        } else if (activity is Tree.Project) {
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
            title: (this.id == 0) ?
              Text('TimeTracker App') :
              Text(name),
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
              IconButton(

                icon: Icon(Icons.search),
                onPressed: () {}, 
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
            onPressed: () => _navigateAcitityAdd(id), 
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
                    onLongPress: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Proyecto ' + _projectList[index].name),
                          content: Column(
                            children: _buildProjectDetails(_projectList[index]),
                          ),
                          actions: <Widget>[
                            FlatButton(
                            child: Text('Cerrar', style: TextStyle(fontSize: 22),),
                            onPressed: () => Navigator.pop(context),
                            )
                          ]
                        );
                      }
                    ),
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
                    onLongPress: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Tarea ' + _taskList[index].name),
                      content: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          setState((){});
                          return Column(
                          children: _buildTaskDetails(_taskList[index])
                        );
                        },
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Cerrar', style: TextStyle(fontSize: 22),),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                      );
                  }
                ),
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
        if (activity is Tree.Task) {
          _taskList.add(activity);
        } else if (activity is Tree.Project) {
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

  List<Widget> _buildTaskDetails(Tree.Task task) {
    String formattedInitialDate = DateFormat('dd-MM-yyyy kk:mm:ss').format(task.initialDate!);
    String formattedFinalDate = DateFormat('dd-MM-yyyy kk:mm:ss').format(task.finalDate!);
                  
    List<Widget> taskDetails = [];

    taskDetails.add(Text('Fecha de creación'));
    taskDetails.add(Center(child: Text(formattedInitialDate)));
    taskDetails.add(Divider());
    taskDetails.add(Text('Fecha de finalización'));
    taskDetails.add(Center(child:Text(formattedFinalDate)));
    taskDetails.add(Divider(height: 50,));

    if (task.active) {
      Tree.Interval interval = task.children.first;
      String formattedIntervalDate = DateFormat('dd-MM-yyyy kk:mm:ss').format(interval.initialDate!);
      taskDetails.add(Text('Esta tarea está activa\ndesde:'));
      taskDetails.add(Divider());
      taskDetails.add(Text(formattedIntervalDate));
      taskDetails.add(Divider());
      taskDetails.add(Text('Tiempo activo:'));
      taskDetails.add(Divider());

      int hours = (interval.duration / 3600).toInt();
    int mins = ((interval.duration / 60) % 60).toInt();
    int secs = (interval.duration % 60);
    String hoursElapsed;
    String minutesElapsed;
    String secondsElapsed;
    if (hours >= 10) {
      hoursElapsed = hours.toString();
    } else {
      hoursElapsed = '0' + hours.toString();
    }

    if (mins >= 10) {
      minutesElapsed = mins.toString();
    } else {
      minutesElapsed = '0' + mins.toString();
    }

    if (secs >= 10) {
      secondsElapsed = secs.toString();
    } else {
      secondsElapsed = '0' + secs.toString();
    }

      taskDetails.add(Text(hoursElapsed + ":" + minutesElapsed + ":" + secondsElapsed));
      taskDetails.add(Divider());
    }

    taskDetails.add(ElevatedButton(
      onPressed: () => Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => PageIntervals(task.id),
    )),
    child: Text('Ver intervalos'),
    ));
    
    

    return taskDetails;
  }

  List<Widget> _buildProjectDetails(Tree.Project project) {
    List<Widget> projectDetails = [];

    String formattedInitialDate = DateFormat('dd-MM-yyyy kk:mm:ss').format(project.initialDate!);
    String formattedFinalDate = DateFormat('dd-MM-yyyy kk:mm:ss').format(project.finalDate!);
    
    projectDetails.add(Text('Fecha de creación'));
    projectDetails.add(Center(child: Text(formattedInitialDate)));
    projectDetails.add(Divider());
    projectDetails.add(Text('Fecha de finalización'));
    projectDetails.add(Center(child:Text(formattedFinalDate)));
    projectDetails.add(Divider(height: 50,));

    int hours = (project.duration / 3600).toInt();
    int mins = ((project.duration / 60) % 60).toInt();
    int secs = (project.duration % 60);
    String hoursElapsed;
    String minutesElapsed;
    String secondsElapsed;
    if (hours >= 10) {
      hoursElapsed = hours.toString();
    } else {
      hoursElapsed = '0' + hours.toString();
    }

    if (mins >= 10) {
      minutesElapsed = mins.toString();
    } else {
      minutesElapsed = '0' + mins.toString();
    }

    if (secs >= 10) {
      secondsElapsed = secs.toString();
    } else {
      secondsElapsed = '0' + secs.toString();
    }
    
    projectDetails.add(Text('Tiempo realizado de trabajo'));
    projectDetails.add(Text(hoursElapsed + ":" + minutesElapsed + ":" + secondsElapsed));
    return projectDetails;
  }
}