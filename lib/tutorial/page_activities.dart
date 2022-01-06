// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:timetracker/TabTasks.dart';
// import 'package:timetracker/tree.dart';
// import 'package:timetracker/PageIntervals.dart';
// import 'package:timetracker/tree.dart' hide getTree;
// import 'package:timetracker/requests.dart' as requests;
// import 'package:timetracker/TabProjects.dart';
// class PageActivities extends StatefulWidget {
//   final int id;

//   PageActivities(this.id);

//   //const PageActivities({ Key? key }) : super(key: key);

//   @override
//   _PageActivitiesState createState() => _PageActivitiesState();
// }

// class _PageActivitiesState extends State<PageActivities> {
//   late int id;
//   late Future<Tree> futureTree;
//   late Timer _timer;
//   static const int periodeRefresh = 2;

//   late List<Widget> listScreens;
//   int tabIndex = 0;
//   @override
//   void initState() {
//     super.initState();

//     id = widget.id;
//     futureTree = requests.getTree(id);
//     listScreens = [
//       TabProjects(id),
//       TabTasks(id),
//     ];
    
    
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
//           return Scaffold(
//             appBar: AppBar(
//               bottom: TabBar(
//                 tabs: listScreens,
//               ),
//               title: Text(snapshot.data!.root.name),
//               actions: <Widget>[
//                 IconButton(icon: Icon(Icons.home),
//                         onPressed: () {} // TODO go home page = root
//                 ),
//                 //TODO other actions
//               ],
//             ),
//             // body: ListView.separated(
//             //   // it's like ListView.builder() but better because it includes a separator between items
//             //   padding: const EdgeInsets.all(16.0),
//             //   itemCount: snapshot.data!.root.children.length,
//             //   itemBuilder: (BuildContext context, int index) =>
//             //           _buildRow(snapshot.data!.root.children[index], index),
//             //   separatorBuilder: (BuildContext context, int index) =>
//             //   const Divider(),
//             // ),
//             body: listScreens[tabIndex],
            
//             bottomNavigationBar: BottomNavigationBar(
              
//               currentIndex: tabIndex,
//               items: [
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.folder),
//                   label: 'Projects',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.note),
//                   label: 'Tasks',
//                 ),
//               ],
//               onTap: (int index) {
//                 setState(() {
//                   tabIndex = index;
//                 });
//               },
//             ),
//           );
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
    
//     // split by '.' and taking first element of resulting list removes the microseconds part
//     if (activity is Project) {
//       return ListTile(
//         title: Text('${activity.name}'),
//         trailing: Text('$strDuration'),
//         onTap: () => _navigateDownActivities(activity.id),
//       );
//     } else if (activity is Task) {
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
//               _refresh();
//             } else {
//               requests.start(activity.id);
//               _refresh();
//             }
//             setState(() {
//               activity.active = !activity.active;
//             });
//           },
//         ),
//         onTap: () => _navigateDownIntervals(activity.id),
//         onLongPress: () {}, // TODO start/stop counting the time for tis task
//       );
//     } else {
//       throw(Exception("Activity that is neither a Task or a Project"));
//       // this solves the problem of return Widget is not nullable because an
//       // Exception is also a Widget?
//     }
//   }

//   void _navigateDownActivities(int childId) {
//     Navigator.of(context)
//         .push(MaterialPageRoute<void>(
//       builder: (context) => PageActivities(childId),
//     ));
//     _activateTimer();
//     _refresh();
//   }

//   void _navigateDownIntervals(int childId) {
//     Navigator.of(context)
//         .push(MaterialPageRoute<void>(
//       builder: (context) => PageIntervals(childId),
//     ));
//     _activateTimer();
//     _refresh();
//   }

//   void _refresh() async {
//     futureTree = requests.getTree(id);
//     setState(() {
          
//         });
//   }

  // void _activateTimer() {
  //   _timer = Timer.periodic(Duration(seconds: periodeRefresh), (Timer t) {
  //     futureTree = requests.getTree(id);
  //     setState(() {});
  //   });
  // }

//   @override
//   void dispose() {
//     // "The framework calls this method when this State object will never build again"
//     // therefore when going up
//     _timer.cancel();
//     super.dispose();
//   }
// }