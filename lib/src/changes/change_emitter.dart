import 'package:notifications/notifications.dart';
import 'package:notifications/src/notification.dart';
import 'package:uuid/uuid.dart';

mixin ChangeEmitter<Model extends ChangeEmitter<Model>> {
  final String changeNotificationName = const Uuid().v1();
  late final Model model;
  bool _shouldNotify = true;
  // make sure re-entrant calls dont send more than 1 notification
  int _totalCalls = 0;

  void changeState(void Function() callback) {
    _totalCalls += 1;
    _shouldNotify = false;

    callback();
    _shouldNotify = true;
    if (_totalCalls == 1) {
      _notify();
    }
    _totalCalls -= 1;
  }

  void _notify() {
    if (_shouldNotify) {
      final n = Notification(name: changeNotificationName, sender: model);
      NotificationCenter.defaultCenter.send(n);
    }
  }
}
