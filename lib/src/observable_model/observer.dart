import 'package:nobust/nobust.dart';
import 'package:nobust/src/notification.dart';
import 'package:nobust/src/observable_model/model.dart';

class Observer {
  void onModelChange(Notification notification) {
    // This is a subclass responsability
    throw UnimplementedError('Subclass responsability');
  }

  void follow(Model model) {
    NotificationCenter.defaultCenter.specificFollow(
        model.changeNotificationName, model, this, onModelChange);
  }

  void unFollow(Model model) {
    NotificationCenter.defaultCenter
        .specificUnfollow(model.changeNotificationName, model, this);
  }
}

class NullObserver extends Observer {
  // Flyweight
  NullObserver._shared();
  static final shared = NullObserver._shared();

  @override
  void onModelChange(Notification notification) {
    // NOP
  }
  @override
  void follow(Model model) {
    // NOP
  }

  @override
  void unFollow(Model model) {
    // NOP
  }
}
