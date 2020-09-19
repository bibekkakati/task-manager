import 'package:flutter/material.dart';
import 'package:todo_app/screens/EditTaskPage.dart';
import 'package:todo_app/screens/ViewTaskPage.dart';
import '../../models/Task.dart';
import '../../blocs/TaskBloc.dart';

class TaskList extends StatefulWidget {
  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  final CurrentTaskBloc _currentTaskBloc = CurrentTaskBloc();

  void _dropDownAction(String action, Task task) {
    switch (action) {
      case "View":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ViewTaskPage(task.id);
            },
          ),
        );

        break;
      case "Edit":
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return EditTaskpage(task);
            },
          ),
        );
        break;
      case "Delete":
        _currentTaskBloc.deleteTaskSink.add(task);
        break;
      case "Completed":
        _currentTaskBloc.completeTasksink.add(task);
        break;
    }
  }

  @override
  void dispose() {
    _currentTaskBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<List<Task>>(
        initialData: [],
        stream: _currentTaskBloc.streamCurrentTaskList,
        builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                color: Colors.white,
                elevation: 0.5,
                shadowColor: Colors.lightBlue[50],
                child: Container(
                  margin: EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.radio_button_checked,
                        color: Colors.lightBlue[200],
                        size: 15.0,
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 2.0, 15.0, 2.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                snapshot.data[index].taskName,
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500),
                              ),
                              Padding(padding: EdgeInsets.all(2.0)),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data[index].date,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey[300],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.all(5.0)),
                                  Text(
                                    snapshot.data[index].time,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey[300],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      dropdownButton(snapshot.data[index]),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  DropdownButton dropdownButton(Task task) {
    List<DropdownMenuItem<dynamic>> items = [
      DropdownMenuItem(
        child: Text(
          'View Task',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        value: 'View',
      ),
      DropdownMenuItem(
        child: Text(
          'Edit task',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        value: 'Edit',
      ),
      DropdownMenuItem(
        child: Text(
          'Delete Task',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        value: 'Delete',
      ),
      DropdownMenuItem(
        child: Text(
          'Mark Completed',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        value: 'Completed',
      ),
    ];
    return DropdownButton(
      underline: SizedBox(
        height: null,
        width: null,
      ),
      icon: Icon(
        Icons.more_horiz,
        color: Colors.grey[500],
      ),
      elevation: 2,
      items: items,
      onChanged: (value) {
        this._dropDownAction(value, task);
      },
    );
  }
}
