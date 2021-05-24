import 'package:nobust/nobust.dart';
import 'package:nobust/src/notification.dart';
import 'package:uuid/uuid.dart';

class Model {
  final String changeNotificationName = const Uuid().v1();

  void notify() {
    final n = Notification(name: changeNotificationName, sender: this);
    NotificationCenter.defaultCenter.send(n);
  }
}
