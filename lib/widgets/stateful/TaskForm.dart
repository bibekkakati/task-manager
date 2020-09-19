import 'package:flutter/material.dart';
import 'package:todo_app/helper_functions/AudioRecordHelper.dart';
import 'package:todo_app/helper_functions/ReminderHelper.dart';
import '../../models/Task.dart';
import '../../blocs/TaskBloc.dart';

class TaskForm extends StatefulWidget {
  final String _id;
  TaskForm(this._id);
  @override
  _TaskFormState createState() => _TaskFormState(this._id);
}

class _TaskFormState extends State<TaskForm> {
  CurrentTaskBloc _currentTaskBloc;
  LocalNotification _localNotification = LocalNotification();

  final String _id;
  _TaskFormState(this._id);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AudioRecordHelper _audioRecordHelper;

  String _date, _time, _taskName = '', _description = '', _recordedAudio;
  bool _isSwitched, _recording;
  int _day, _month, _year, _hour, _minute;

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

  void _recordButtonClicked() async {
    if (this._recording) {
      bool stopped = await _audioRecordHelper.stopRecording();
      if (stopped) {
        setState(() {
          this._recording = false;
          this._recordedAudio = '${this._id}.aac';
        });
      }
    } else {
      bool started = await _audioRecordHelper.startRecording();
      if (started) {
        setState(() {
          this._recording = true;
        });
      }
    }
  }

  void _deleteRecordedAudio() async {
    if (this._recordedAudio != null && this._recording == false) {
      bool deleted = await _audioRecordHelper.deleteRecording();
      if (deleted) {
        setState(() {
          this._recordedAudio = null;
        });
      }
    }
  }

  void _reminder(int timestampInMS) {
    if (this._isSwitched) {
      int notificationId = DateTime.now().millisecondsSinceEpoch;
      notificationId = (notificationId / 1000).floor();
      _localNotification.subscribeNotification(
          notificationId, this._id, this._taskName, timestampInMS);
    }
  }

  void _createTask() {
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
      bool audioDescription = this._recordedAudio == null ? false : true;
      Task task = Task(this._id, this._taskName, this._description, this._date,
          this._time, audioDescription, timestamp);
      this._reminder(timestamp - DateTime.now().millisecondsSinceEpoch);
      _currentTaskBloc = CurrentTaskBloc();
      _currentTaskBloc.addTaskSink.add(task);
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Task Created')));
      Navigator.of(context).pop();
    } else {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Task Creation Failed')));
    }
  }

  @override
  void initState() {
    this._isSwitched = false;
    this._recording = false;
    this._audioRecordHelper = AudioRecordHelper(this._id);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _audioRecordHelper.dispose();
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
                    child: this._recordedAudio != null
                        ? null
                        : RaisedButton(
                            padding:
                                EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            onPressed: this._recordButtonClicked,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  this._recording == true
                                      ? 'Stop Recording'
                                      : 'Start Recording',
                                  style: TextStyle(
                                    color: this._recording == true
                                        ? Colors.red
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.0,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Icon(
                                  Icons.mic,
                                  color: this._recording == true
                                      ? Colors.red
                                      : Colors.lightBlue[200],
                                ),
                              ],
                            ),
                          ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    child: this._recordedAudio == null
                        ? null
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recorded Audio',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15.0,
                                  letterSpacing: 1.0,
                                ),
                              ),
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
            onPressed: this._createTask,
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
                  'CREATE TASK',
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
