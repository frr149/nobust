import 'package:notifications/notifications.dart';
import 'package:notifications/src/notification.dart';
import 'package:notifications/src/changes/change_emitter.dart';

mixin ChangeReceiver<Model extends ChangeEmitter<Model>> {
  late final Model host;

  void start(void Function() callback) {
    NotificationCenter.defaultCenter.specificFollow(
        host.changeNotificationName, host, this, (Notification n) {
      callback();
    });
  }

  void stop() {
    NotificationCenter.defaultCenter
        .specificUnfollow(host.changeNotificationName, host, this);
  }
}
