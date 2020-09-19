import 'package:flutter/material.dart';
import 'package:todo_app/helper_functions/AudioRecordHelper.dart';
import 'package:todo_app/helper_functions/DatabaseHelper.dart';
import 'package:todo_app/helper_functions/ReminderHelper.dart';
import 'package:todo_app/models/Task.dart';

class TaskDetails extends StatefulWidget {
  final String _id;
  TaskDetails(this._id);
  @override
  _TaskDetailsState createState() => _TaskDetailsState(this._id);
}

class _TaskDetailsState extends State<TaskDetails> {
  final String _id;
  _TaskDetailsState(this._id);

  DatabaseHelper _databaseHelper = DatabaseHelper();
  LocalNotification _localNotification = LocalNotification();
  AudioPlayerHelper _audioPlayerHelper;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _taskNameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  Task _task;
  bool _isLoading = false;
  bool _playing = false, _recordedAudio, _isSwitched = false;

  void _getTaskDetails(String id) async {
    List<Task> taskList = await _databaseHelper.getCurrentTask(id);
    if (taskList.length > 0) {
      _taskNameController.text = taskList[0].taskName;
      _descriptionController.text = taskList[0].description;
      setState(() {
        this._task = taskList[0];
        this._recordedAudio = taskList[0].audioDescription;
      });
    }
    setState(() {
      this._isLoading = false;
    });
  }

  void _playRecording() async {
    this._audioPlayerHelper = AudioPlayerHelper(this._id);
    if (!this._playing && _recordedAudio != null) {
      var playing = await _audioPlayerHelper.startPlaying();
      if (playing) {
        setState(() {
          this._playing = true;
        });
      }
    } else {
      var stopped = await _audioPlayerHelper.stopPlaying();
      if (stopped) {
        setState(() {
          this._playing = false;
        });
      }
    }
  }

  void _ifOptedForReminder() async {
    int notificationId =
        await _localNotification.checkIfOptedForNotification(this._id);
    if (notificationId > 0) {
      setState(() {
        this._isSwitched = true;
      });
    } else {
      setState(() {
        this._isSwitched = false;
      });
    }
  }

  @override
  void initState() {
    this._isLoading = true;
    this._getTaskDetails(this._id);
    this._ifOptedForReminder();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return this._isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : dataContainer();
  }

  Container dataContainer() {
    return Container(
      child: this._task == null
          ? Center(
              child: Text(
                'No Task Available',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  child: Form(
                    key: this._formKey,
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextFormField(
                            enabled: false,
                            controller: this._taskNameController,
                            decoration: InputDecoration(
                              labelText: 'Task Name',
                              alignLabelWithHint: true,
                              contentPadding: EdgeInsets.all(15.0),
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0)),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            enabled: false,
                            maxLines: 8,
                            controller: this._descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              alignLabelWithHint: true,
                              contentPadding: EdgeInsets.all(15.0),
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0)),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            child: this._recordedAudio != true
                                ? null
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Recorded Audio',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15.0,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: _playRecording,
                                        icon: this._playing
                                            ? Icon(Icons.pause_circle_filled)
                                            : Icon(Icons.play_circle_filled),
                                        color: Colors.lightBlue[300],
                                      ),
                                    ],
                                  ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RaisedButton(
                                padding:
                                    EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                onPressed: () {},
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                color: Colors.white,
                                child: Row(
                                  children: [
                                    Text(
                                      this._task.date,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15.0,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.all(10.0)),
                                    Icon(
                                      Icons.date_range,
                                      color: Colors.lightBlue[200],
                                    ),
                                  ],
                                ),
                              ),
                              RaisedButton(
                                padding:
                                    EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                onPressed: () {},
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                color: Colors.white,
                                child: Row(
                                  children: [
                                    Text(
                                      this._task.time,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15.0,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.all(10.0)),
                                    Icon(
                                      Icons.timer,
                                      color: Colors.lightBlue[200],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.notifications_active,
                                color: Colors.lightBlue[200],
                              ),
                              Padding(padding: EdgeInsets.all(10.0)),
                              Text(
                                'Remind Me',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.0,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Switch(
                                    value: _isSwitched,
                                    onChanged: (value) {},
                                    activeTrackColor: Colors.lightBlueAccent,
                                    activeColor: Colors.lightBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
