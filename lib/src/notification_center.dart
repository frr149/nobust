import 'package:nobust/src/notification.dart';

class _Follower {
  late final String _name;
  late final Object _receiver;
  late final void Function(Notification notification) _callback;

  String get name => _name;
  Object get receiver => _receiver;

  _Follower(String name, Object receiver,
      void Function(Notification notification) callback)
      : _name = name,
        _receiver = receiver,
        _callback = callback;

  void operator(Notification notification) {
    _callback(notification);
  }
}

class NotificationCenter {
  // Singleton
  NotificationCenter._defaultCenter();
  static final defaultCenter = NotificationCenter._defaultCenter();

  // NotificationQueue
  final List<_Follower> _queue = [];

  // Follow / Unfollow
  void follow(String name, Object receiver,
      void Function(Notification notification) callback) {
    _queue.add(_Follower(name, receiver, callback));
  }
}
