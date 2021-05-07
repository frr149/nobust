import 'package:nobust/src/notification.dart';
import 'package:meta/meta.dart';

class NotificationCenter {
  // Singleton
  NotificationCenter._defaultCenter();
  static final defaultCenter = NotificationCenter._defaultCenter();

  // NotificationQueue
  List<UniversalFollower> _queue = [];

  /// Follow every single notification with htis name, no matter who sends it
  void followAll(String name, Object receiver, NotificationCallback callback) {
    final follower = UniversalFollower(name, receiver, callback);
    if (!_queue.contains(follower)) {
      _queue.add(follower);
    }
  }

  /// Unfollow this notification name, no matter from who
  void unFollowAll(String name, Object receiver) {
    _queue.removeWhere(
        (element) => element._name == name && element._receiver == receiver);
  }

  // Send
  void send(Notification notification) {
    _queue.forEach((element) {
      if (element.isFollowing(notification)) {
        element.notify(notification);
      }
    });
  }

  /// Removes all followers from the list. Used for testing mostly.
  void zap() {
    _queue = [];
  }

  int get length => _queue.length;
}

typedef NotificationCallback = void Function(Notification notification);

/// Class that wraps together the name of the notification, the follower and t
/// he callback we must call.
/// Implements following a notification, no matter who sends it
@visibleForTesting
class UniversalFollower {
  late final String _name;
  late final Object _receiver;
  late final NotificationCallback _callback;

  String get name => _name;
  Object get receiver => _receiver;

  UniversalFollower(String name, Object receiver, NotificationCallback callback)
      : _name = name,
        _receiver = receiver,
        _callback = callback;

  bool isFollowing(Notification notification) {
    return notification.name == name;
  }

  void notify(Notification notification) {
    _callback(notification);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else {
      return other is UniversalFollower &&
          name == other.name &&
          receiver == other.receiver;
    }
  }

  @override
  int get hashCode {
    return name.hashCode ^ receiver.hashCode;
  }
}
