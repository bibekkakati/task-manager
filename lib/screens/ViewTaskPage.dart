import 'package:flutter/material.dart';
import 'package:todo_app/widgets/stateful/TaskDetails.dart';

class ViewTaskPage extends StatelessWidget {
  final String _id;
  ViewTaskPage(this._id);

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
          'Task Details',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: TaskDetails(this._id),
    );
  }
}
