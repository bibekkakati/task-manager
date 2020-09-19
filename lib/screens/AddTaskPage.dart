import 'package:flutter/material.dart';
import 'package:todo_app/helper_functions/AudioRecordHelper.dart';
import './../widgets/stateful/TaskForm.dart';
import 'package:uuid/uuid.dart';

class AddTaskPage extends StatelessWidget {
  final String _id = Uuid().v1();

  void _navigateToPreviousScreen(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<bool> _backButtonPressed(context) {
    AudioRecordHelper _audioRecorderHelper = AudioRecordHelper(this._id);
    _audioRecorderHelper.deleteRecording();
    return Future<bool>.value(true);
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
          'Create New Task',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () => this._backButtonPressed(context),
        child: SingleChildScrollView(
          child: TaskForm(this._id),
        ),
      ),
    );
  }
}
