import 'package:flutter/material.dart';
import 'package:todo_app/widgets/stateful/CompletedTaskList.dart';

class CompletedTaskPage extends StatelessWidget {
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
          'Completed Task',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(child: CompletedTaskList()),
    );
  }
}
