import 'package:flutter/material.dart';
import 'package:todo_app/models/Task.dart';
import 'package:todo_app/widgets/stateful/EditTaskForm.dart';

class EditTaskpage extends StatelessWidget {
  final Task _task;
  EditTaskpage(this._task);

  void _navigateToPreviousScreen(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            _navigateToPreviousScreen(context);
          },
        ),
        title: Text(
          'Update Task',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: EditTaskForm(this._task),
      ),
    );
  }
}
