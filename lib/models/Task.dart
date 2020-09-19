class Task {
  String _id;
  String _taskName;
  String _description;
  String _date;
  String _time;
  bool _audioDescription;
  int _timestamp;

  Task(this._id, this._taskName, this._description, this._date, this._time,
      this._audioDescription, this._timestamp);

  String get id => this._id;
  String get taskName => this._taskName;
  String get description => this._description;
  String get date => this._date;
  String get time => this._time;
  bool get audioDescription => this._audioDescription;
  int get timestamp => this._timestamp;

  set id(String id) {
    this._id = id;
  }

  set taskName(String taskName) {
    this._taskName = taskName;
  }

  set description(String description) {
    this._description = description;
  }

  set date(String date) {
    this._date = date;
  }

  set time(String time) {
    this._time = time;
  }

  set audioDescription(bool state) {
    this._audioDescription = state;
  }

  set timestamp(int timestamp) {
    this._timestamp = timestamp;
  }

  //convert task object to map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (this.id != null) {
      map['id'] = this.id;
    }
    map['taskName'] = this.taskName;
    map['description'] = this.description;
    map['date'] = this.date;
    map['time'] = this.time;
    map['audioDescription'] = this.audioDescription ? 1 : 0;
    map['timestamp'] = this.timestamp;

    return map;
  }

  Task.fromMapObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.taskName = map['taskName'];
    this.description = map['description'];
    this.date = map['date'];
    this.time = map['time'];
    this.audioDescription = map['audioDescription'] > 0 ? true : false;
    this.timestamp = map['timestamp'];
  }
}
