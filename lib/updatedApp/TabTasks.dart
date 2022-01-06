// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:timetracker/tree.dart';
// import 'package:timetracker/requests.dart' as requests;
// import 'package:timetracker/PageIntervals.dart';
// class TabTasks extends StatefulWidget {
//   final int id;
  
//   TabTasks(this.id);
//   @override
//   _TabTasksState createState() => _TabTasksState();
// }

// class _TabTasksState extends State<TabTasks> {
//   late int id;
//   late Future<Tree> futureTree;
//   late Timer _timer;
//   static const int periodeRefresh = 2;

//   late List<Widget> listScreens;
//   int tabIndex = 0;

//     void _refresh() async {
//     futureTree = requests.getTree(id);
//     setState(() {});
//   }

//  void _activateTimer() {
//     _timer = Timer.periodic(Duration(seconds: periodeRefresh), (Timer t) {
//       futureTree = requests.getTree(id);
//       setState(() {});
//     });
//   }

//   void _navigateDownIntervals(int childId) {
//     Navigator.of(context)
//         .push(MaterialPageRoute<void>(
//       builder: (context) => PageIntervals(childId),
//     ));
//     _activateTimer();
//     _refresh();
//   }

//   @override
//   void initState() {
//     super.initState();
//     id = widget.id;
//     futureTree = requests.getTree(id);
//     _activateTimer();
//   }
  
//   // future with listview
//   // https://medium.com/nonstopio/flutter-future-builder-with-list-view-builder-d7212314e8c9
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Tree>(
//       future: futureTree,
//       // this makes the tree of children, when available, go into snapshot.data
//       builder: (context, snapshot) {
//         // anonymous function
//         if (snapshot.hasData) {
//           return ListView.builder(
//               // it's like ListView.builder() but better because it includes a separator between items
//               padding: const EdgeInsets.all(16.0),
//               itemCount: snapshot.data!.root.children.length,
//               itemBuilder: (BuildContext context, int index) =>
//                       _buildRow(snapshot.data!.root.children[index], index),
            
//             );
//         } else if (snapshot.hasError) {
//           return Text("${snapshot.error}");
//         }
//         // By default, show a progress indicator
//         return Container(
//                 height: MediaQuery.of(context).size.height,
//                 color: Colors.white,
//                 child: Center(
//                   child: CircularProgressIndicator(),
//                 ));
//       },
//     );
//   }

  

//   Widget _buildRow(Activity activity, int index) {
//     String strDuration = Duration(seconds: activity.duration).toString().split('.').first;
    
//     if (activity is Task) {
//       Task task = activity as Task;
//       // at the moment is the same, maybe changes in the future
//       Widget trailing;
//       trailing = Text('$strDuration');
//       return ListTile(
//         title: Text('${activity.name}'),
//         subtitle: trailing,
//         trailing: Switch(
//           value: activity.active,
//           activeColor: Colors.green,
//           onChanged: (change) {
//             if (activity.active) {
//               requests.stop(activity.id);
//               //_refresh();
//             } else {
//               requests.start(activity.id);
//               //_refresh();
//             }
//             setState(() {
//               activity.active = !activity.active;
//             });
//           },
//         ),
//         onTap: () => _navigateDownIntervals(activity.id),
//         onLongPress: () {}, // TODO start/stop counting the time for tis task
//       );
//     }
//     return SizedBox.shrink();
//   }

// }