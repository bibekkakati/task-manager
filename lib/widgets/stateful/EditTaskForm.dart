import 'package:flutter/material.dart';
import 'package:todo_app/blocs/TaskBloc.dart';
import 'package:todo_app/helper_functions/AudioRecordHelper.dart';
import 'package:todo_app/helper_functions/ReminderHelper.dart';
import 'package:todo_app/models/Task.dart';

class EditTaskForm extends StatefulWidget {
  final Task _task;
  EditTaskForm(this._task);
  @override
  _EditTaskFormState createState() => _EditTaskFormState(this._task);
}

class _EditTaskFormState extends State<EditTaskForm> {
  final Task _task;
  _EditTaskFormState(this._task);

  CurrentTaskBloc _currentTaskBloc = CurrentTaskBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AudioPlayerHelper _audioPlayerHelper;
  AudioRecordHelper _audioRecordHelper;
  LocalNotification _localNotification = LocalNotification();

  String _date, _time, _taskName, _description;
  bool _isSwitched = false, _recordedAudio, _playing;
  int _day, _month, _year, _hour, _minute, _notificationId;

  //TEXT EDITING CONTROLLER
  TextEditingController _taskNameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  String _validateTaskName(String value) {
    if (value.length <= 0) {
      return 'Task Name is required';
    }
    return null;
  }

  void _pickDate() async {
    DateTime selectedDate = DateTime.now();
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(selectedDate.year),
        lastDate: DateTime(selectedDate.year + 2));
    if (picked != null && picked != selectedDate) {
      this._day = picked.day;
      this._month = picked.month;
      this._year = picked.year;
      setState(() {
        this._date = '${this._day}/${this._month}/${this._year}';
      });
    }
  }

  void _pickTime() async {
    TimeOfDay selectedTime = TimeOfDay.now();
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null && picked != selectedTime) {
      String meridian;
      this._minute = picked.minute;
      String minute =
          this._minute < 10 ? '0${this._minute}' : '${this._minute}';
      this._hour = picked.hour;
      String hour = this._hour < 10 ? '0${this._hour}' : '${this._hour}';
      if (this._hour >= 12) {
        meridian = 'PM';
      } else {
        meridian = 'AM';
      }
      setState(() {
        this._time = '$hour:$minute $meridian';
      });
    }
  }

  void _updateTask() {
    if (_formKey.currentState.validate() &&
        this._day != null &&
        this._month != null &&
        this._year != null &&
        this._hour != null &&
        this._minute != null) {
      _formKey.currentState.save();
      int timestamp =
          DateTime(this._year, this._month, this._day, this._hour, this._minute)
              .millisecondsSinceEpoch;
      this._task.taskName = this._taskName;
      this._task.description = this._description;
      this._task.date = this._date;
      this._task.time = this._time;
      this._task.audioDescription = this._recordedAudio;
      this._task.timestamp = timestamp;
      this._reminder(timestamp - DateTime.now().millisecondsSinceEpoch);
      _currentTaskBloc.updateTaskSink.add(this._task);
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Task Updated')));
      Navigator.of(context).pop();
    } else {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Task Updation Failed')));
    }
  }

  void _deleteRecordedAudio() async {
    this._audioRecordHelper = AudioRecordHelper(this._task.id);
    if (this._recordedAudio != null) {
      bool deleted = await _audioRecordHelper.deleteRecording();
      if (deleted) {
        setState(() {
          this._recordedAudio = false;
        });
      }
    }
  }

  void _playRecording() async {
    _audioPlayerHelper = AudioPlayerHelper(this._task.id);
    if (!this._playing && this._recordedAudio != null) {
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
        await _localNotification.checkIfOptedForNotification(this._task.id);
    if (notificationId > 0) {
      setState(() {
        this._notificationId = notificationId;
        this._isSwitched = true;
      });
    } else {
      setState(() {
        this._isSwitched = false;
      });
    }
  }

  void _structimestamp() {
    DateTime timestamp =
        DateTime.fromMillisecondsSinceEpoch(this._task.timestamp);
    this._day = timestamp.day;
    this._month = timestamp.month;
    this._year = timestamp.year;
    this._hour = timestamp.hour;
    this._minute = timestamp.minute;
  }

  void _reminder(int timestampInMS) {
    if (this._notificationId != null) {
      _localNotification.unsubscribeNotification(this._notificationId);
      if (this._isSwitched) {
        _localNotification.subscribeNotification(
            this._notificationId, this._task.id, this._taskName, timestampInMS);
      }
    } else {
      if (this._isSwitched) {
        int notificationId = DateTime.now().millisecondsSinceEpoch;
        notificationId = (notificationId / 1000).floor();
        _localNotification.subscribeNotification(
            notificationId, this._task.id, this._taskName, timestampInMS);
      }
    }
  }

  @override
  void dispose() {
    _currentTaskBloc.dispose();
    if (this._audioRecordHelper != null) {
      _audioRecordHelper.dispose();
    }

    super.dispose();
  }

  @override
  void initState() {
    _taskNameController.text = this._task.taskName;
    _descriptionController.text = this._task.description;
    this._taskName = this._task.taskName;
    this._description = this._task.description;
    this._recordedAudio = this._task.audioDescription;
    this._date = this._task.date;
    this._time = this._task.time;
    this._playing = false;
    this._ifOptedForReminder();
    this._structimestamp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          child: Form(
            key: this._formKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    maxLength: 50,
                    controller: this._taskNameController,
                    decoration: InputDecoration(
                      labelText: 'Task Name',
                      alignLabelWithHint: true,
                      contentPadding: EdgeInsets.all(15.0),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                    ),
                    validator: this._validateTaskName,
                    onSaved: (input) => _taskName = input,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    maxLines: 4,
                    controller: this._descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                      contentPadding: EdgeInsets.all(15.0),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                    ),
                    onSaved: (input) => _description = input,
                  ),
                  SizedBox(height: 20),
                  Container(
                    child: this._recordedAudio != true
                        ? null
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              Padding(padding: EdgeInsets.all(10.0)),
                              IconButton(
                                onPressed: _deleteRecordedAudio,
                                icon: Icon(Icons.delete),
                                color: Colors.red[300],
                              ),
                            ],
                          ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RaisedButton(
                        padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        onPressed: this._pickDate,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        color: Colors.white,
                        child: Row(
                          children: [
                            Text(
                              this._date == null ? 'Select Date' : this._date,
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
                        padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        onPressed: this._pickTime,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        color: Colors.white,
                        child: Row(
                          children: [
                            Text(
                              this._time == null ? 'Select Time' : this._time,
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
                            onChanged: (value) {
                              setState(() {
                                _isSwitched = value;
                              });
                            },
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
        Container(
          height: 65,
          width: 250,
          padding: EdgeInsets.all(10.0),
          child: RaisedButton(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            onPressed: this._updateTask,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            color: Colors.lightBlue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle,
                  color: Colors.white,
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                Text(
                  'UPDATE TASK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18.0,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
