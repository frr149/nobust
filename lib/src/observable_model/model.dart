import 'package:nobust/nobust.dart';
import 'package:nobust/src/notification.dart';
import 'package:uuid/uuid.dart';
import 'package:nobust/src/observable_model/observer.dart';

class Model {
  final String changeNotificationName = const Uuid().v1();
  Observer _observer = NullObserver.shared;

  Observer get observer => _observer;
  set observer(Observer newOne) {
    _observer.unFollow(this);
    _observer = newOne;
    _observer.follow(this);
  }

  void notify() {
    final n = Notification(name: changeNotificationName, sender: this);
    NotificationCenter.defaultCenter.send(n);
  }
}
