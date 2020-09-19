import 'dart:async';
import '../models/Task.dart';
import '../helper_functions/DatabaseHelper.dart';

class CurrentTaskBloc {
  static CurrentTaskBloc _currentTaskBloc;
  DatabaseHelper databaseHelper = DatabaseHelper();

  // *** STREAM CONTROLLERS ***
  final _currentTaskListStreamController = StreamController<List<Task>>();
  final _addTaskStreamController = StreamController<Task>();
  final _editTaskStreamController = StreamController<Task>();
  final _deleteTaskStreamController = StreamController<Task>();
  final _completeTaskStreamController = StreamController<Task>();

  // *** STREAM ***
  Stream<List<Task>> get streamCurrentTaskList =>
      _currentTaskListStreamController.stream;

  // *** STREAM SINK ***
  StreamSink<List<Task>> get currentTaskListSink =>
      _currentTaskListStreamController.sink;
  StreamSink<Task> get addTaskSink => _addTaskStreamController.sink;
  StreamSink<Task> get updateTaskSink => _editTaskStreamController.sink;
  StreamSink<Task> get deleteTaskSink => _deleteTaskStreamController.sink;
  StreamSink<Task> get completeTasksink => _completeTaskStreamController.sink;

  CurrentTaskBloc._createInstance();
  factory CurrentTaskBloc() {
    if (_currentTaskBloc == null) {
      _currentTaskBloc = CurrentTaskBloc._createInstance();
      _currentTaskBloc.init();
    }
    return _currentTaskBloc;
  }

  // *** INITIALIZE STREAM CONTROLLERS ***
  void init() {
    _getTaskListUpdateStream();
    _addTaskStreamController.stream.listen(_addTask);
    _editTaskStreamController.stream.listen(_editTask);
    _deleteTaskStreamController.stream.listen(_deleteTask);
    _completeTaskStreamController.stream.listen(_completeTask);
  }

  // *** GET CURRENT TASKS LIST AND UPDATE STREAM ***
  void _getTaskListUpdateStream() {
    Future<List<Task>> taskListFuture =
        databaseHelper.getCurrentTaskObjectList();
    taskListFuture.then((taskList) {
      _currentTaskListStreamController.add(taskList);
    });
  }

  // *** INSERT TASK IN DATABASE
  void _addTask(Task task) async {
    int result = await databaseHelper.insertTask(task);
    if (result > 0) {
      _getTaskListUpdateStream();
    }
  }

  // *** UPDATE TASK IN DATABASE ***
  void _editTask(Task task) async {
    int result = await databaseHelper.updateTask(task);
    if (result > 0) {
      _getTaskListUpdateStream();
    }
  }

  void _deleteTask(Task task) async {
    int result = await databaseHelper.deleteCurrentTask(task);
    if (result > 0) {
      _getTaskListUpdateStream();
    }
  }

  void _completeTask(Task task) async {
    int result = await databaseHelper.completeTask(task);
    if (result > 0) {
      _getTaskListUpdateStream();
    }
  }

  void dispose() {
    _currentTaskListStreamController.close();
    _addTaskStreamController.close();
    _editTaskStreamController.close();
    _deleteTaskStreamController.close();
    _completeTaskStreamController.close();
  }
}

class CompletedTaskBloc {
  DatabaseHelper databaseHelper = DatabaseHelper();
  CurrentTaskBloc _currentTaskBloc = CurrentTaskBloc();

  // *** STREAM CONTROLLERS ***
  final _completedTaskListStreamController = StreamController<List<Task>>();
  final _deleteTaskStreamController = StreamController<Task>();
  final _undoCompleteTaskStreamController = StreamController<Task>();

  // *** STREAM ***
  Stream<List<Task>> get streamCompletedTaskList =>
      _completedTaskListStreamController.stream;

  // *** STREAM SINK ***
  StreamSink<List<Task>> get completedTaskListSink =>
      _completedTaskListStreamController.sink;
  StreamSink<Task> get deleteTaskSink => _deleteTaskStreamController.sink;
  StreamSink<Task> get undoCompleteTasksink =>
      _undoCompleteTaskStreamController.sink;

  // *** CONSTRUCTOR ***
  CompletedTaskBloc() {
    this.init();
  }

  // *** INITIALIZE STREAM CONTROLLERS ***
  void init() {
    this._getTaskListUpdateStream();
    _deleteTaskStreamController.stream.listen(_deleteTask);
    _undoCompleteTaskStreamController.stream.listen(_undoCompleteTask);
  }

  // *** GET CURRENT TASKS LIST AND UPDATE STREAM ***
  void _getTaskListUpdateStream() {
    Future<List<Task>> taskListFuture =
        databaseHelper.getCompletedTaskObjectList();
    taskListFuture.then((taskList) {
      _completedTaskListStreamController.add(taskList);
    });
  }

  void _deleteTask(Task task) async {
    int result = await databaseHelper.deleteCompletedTask(task);
    if (result > 0) {
      this._getTaskListUpdateStream();
    }
  }

  void _undoCompleteTask(Task task) async {
    int result = await databaseHelper.undoCompleteTask(task);
    if (result > 0) {
      _currentTaskBloc._getTaskListUpdateStream();
    }
  }

  void dispose() {
    _completedTaskListStreamController.close();
    _deleteTaskStreamController.close();
    _undoCompleteTaskStreamController.close();
  }
}
