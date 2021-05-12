import 'package:nobust/src/notification.dart';
import 'package:meta/meta.dart';

typedef NotificationCallback = void Function(Notification notification);

/// Class that wraps together the name of the notification, the follower and t
/// he callback we must call.
class Follower {
  late final String _name;
  late final Object _receiver;
  late final NotificationCallback _callback;

  String get name => _name;
  Object get receiver => _receiver;

  Follower(String name, Object receiver, NotificationCallback callback)
      : _name = name,
        _receiver = receiver,
        _callback = callback;

  factory Follower.topicFollower(
      String name, Object receiver, NotificationCallback callback) {
    return TopicFollower(name, receiver, callback);
  }

  factory Follower.fanFollower(
      Object sender, Object receiver, NotificationCallback callback) {
    return FanFollower(sender, receiver, callback);
  }

  factory Follower.compositeFollower(String name, Object sender,
      Object receiver, NotificationCallback callback) {
    return CompositeFollower(name, receiver, sender, callback);
  }

  bool isFollowing(Notification notification) {
    throw UnimplementedError();
  }

  void notify(Notification notification) {
    _callback(notification);
  }
}

/// Implements following a notification, no matter who sends it
@visibleForTesting
class TopicFollower extends Follower {
  TopicFollower(String name, Object receiver, NotificationCallback callback)
      : super(name, receiver, callback);

  @override
  bool isFollowing(Notification notification) {
    return notification.name == name;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else {
      return other is TopicFollower &&
          name == other.name &&
          receiver == other.receiver;
    }
  }

  @override
  int get hashCode => name.hashCode ^ receiver.hashCode;
}

/// FanFollower: follows everything a given sender emits
class FanFollower extends Follower {
  late final Object _sender;
  static const String _kAny = 'any';

  FanFollower(Object sender, Object receiver, NotificationCallback callback)
      : _sender = sender,
        super(_kAny, receiver, callback);

  @override
  bool isFollowing(Notification notification) {
    // compare only the sender
    return notification.sender == _sender;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else {
      return other is FanFollower &&
          _sender == other._sender &&
          _receiver == other._receiver;
    }
  }

  @override
  int get hashCode {
    return _sender.hashCode ^ receiver.hashCode;
  }
}

class CompositeFollower extends Follower {
  late FanFollower _fan;
  late TopicFollower _topic;

  CompositeFollower(String name, Object receiver, Object sender,
      NotificationCallback callback)
      : super(name, receiver, callback) {
    _fan = FanFollower(sender, receiver, callback);
    _topic = TopicFollower(name, receiver, callback);
  }

  @override
  bool isFollowing(Notification notification) {
    return _fan.isFollowing(notification) && _topic.isFollowing(notification);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else {
      return other is CompositeFollower &&
          _fan == other._fan &&
          _topic == other._topic;
    }
  }

  @override
  // TODO: implement hashCode
  int get hashCode => _fan.hashCode ^ _topic.hashCode;
}
