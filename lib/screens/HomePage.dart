import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:todo_app/helper_functions/ReminderHelper.dart';
import 'package:todo_app/screens/CompletedTaskPage.dart';
import 'package:todo_app/screens/ViewTaskPage.dart';
import '../helper_functions/DateTimeHelper.dart';
import './../widgets/stateful/TaskList.dart';
import './AddTaskPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LocalNotification _localNotification = LocalNotification();

  String _date = 'Task Manager';

  void _navigateToAddTaskScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return AddTaskPage();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    var now = new DateTime.now();
    String weekday = getWeekday(now.weekday);
    String month = getMonth(now.month);
    int day = now.day;
    this._date = '$weekday $day, $month';
    _localNotification.init(
        this.selectNotification, this.onDidReceiveLocalNotification);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          this._date,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).appBarTheme.color,
      ),
      body: Container(
        child: TaskList(),
      ),
      bottomNavigationBar: buildBottomNavigationBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: this._navigateToAddTaskScreen,
        mini: true,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
    );
  }

  BottomNavigationBar buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.dashboard,
            color: Color(0xffbebebe),
          ),
          activeIcon: Icon(
            Icons.dashboard,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(''),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.assignment_turned_in,
            color: Color(0xffbebebe),
          ),
          activeIcon: Icon(
            Icons.assignment_turned_in,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(''),
        ),
      ],
      onTap: (index) {
        if (index == 1) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (builder) {
              return CompletedTaskPage();
            },
          ));
        }
      },
    );
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewTaskPage(payload),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Future selectNotification(String payload) {
    return Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ViewTaskPage(payload);
    }));
  }
}
