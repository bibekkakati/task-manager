import 'package:flutter/material.dart';
import 'package:todo_app/screens/ViewTaskPage.dart';
import '../../models/Task.dart';
import '../../blocs/TaskBloc.dart';

class CompletedTaskList extends StatefulWidget {
  @override
  _CompletedTaskListState createState() => _CompletedTaskListState();
}

class _CompletedTaskListState extends State<CompletedTaskList> {
  final CompletedTaskBloc _completedTaskBloc = CompletedTaskBloc();

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
      case "Delete":
        _completedTaskBloc.deleteTaskSink.add(task);
        break;
      case "NotCompleted":
        _completedTaskBloc.undoCompleteTasksink.add(task);
        break;
    }
  }

  @override
  void dispose() {
    _completedTaskBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<List<Task>>(
        initialData: [],
        stream: _completedTaskBloc.streamCompletedTaskList,
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
          'Not Completed',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        value: 'NotCompleted',
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
