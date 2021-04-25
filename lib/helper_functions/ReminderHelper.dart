import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static LocalNotification _localNotification;

  var selectNotification, onDidReceiveLocalNotification;

  // *** CONSTRUCTOR ***
  LocalNotification._createInstance();
  factory LocalNotification() {
    if (_localNotification == null) {
      _localNotification = LocalNotification._createInstance();
      _localNotification.inititialize();
    }
    return _localNotification;
  }

  void init(selectNotification, onDidReceiveLocalNotification) {
    if (this.selectNotification == null) {
      this.selectNotification = selectNotification;
    }
    if (this.onDidReceiveLocalNotification == null) {
      this.onDidReceiveLocalNotification = onDidReceiveLocalNotification;
    }
  }

  void inititialize() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  Future subscribeNotification(
      int notificationId, String taskId, String name, int timestampInMS) async {
    var androidDetails = AndroidNotificationDetails(
        "TaskNotification", "Scheduled Task", 'Reminder for task completion',
        importance: Importance.Max,
        priority: Priority.High,
        ongoing: true,
        visibility: NotificationVisibility.Public,
        styleInformation: BigTextStyleInformation(''));
    var iosDetails = IOSNotificationDetails();
    var generalNotificationDetails =
        NotificationDetails(androidDetails, iosDetails);

    var scheduledTime =
        DateTime.now().add(Duration(milliseconds: timestampInMS));

    try {
      await flutterLocalNotificationsPlugin.schedule(notificationId, name,
          'You have a task', scheduledTime, generalNotificationDetails,
          payload: taskId);
    } catch (e) {}
  }

  Future<int> checkIfOptedForNotification(String taskId) async {
    int result = 0;
    try {
      List<PendingNotificationRequest> list =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      if (list.length > 0) {
        for (var i = 0; i < list.length; ++i) {
          if (list[0].payload == taskId) {
            result = list[0].id;
            break;
          }
        }
      }
      return result;
    } catch (e) {
      return result;
    }
  }

  Future<bool> unsubscribeNotification(int notificationId) async {
    // int notificationId = await this.checkIfOptedForNotification(taskId);
    if (notificationId > 0) {
      try {
        await flutterLocalNotificationsPlugin.cancel(notificationId);
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }
}
