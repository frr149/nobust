import 'dart:async';

import 'package:meta/meta.dart';
import 'package:nobust/src/notification.dart';
import 'package:nobust/src/followers.dart';

class NotificationCenter {
  int get length => _queue.length;

  // Singleton
  NotificationCenter._defaultCenter();
  static final defaultCenter = NotificationCenter._defaultCenter();

  // NotificationQueue
  List<Follower> _queue = [];

  // adds / removes followers to the queue
  void _follow(Follower follower) {
    if (!_queue.contains(follower)) {
      _queue.add(follower);
    }
  }

  void _unfollow(Follower follower) {
    _queue.remove(follower);
  }

  /// Follow every single notification with htis name, no matter who sends it
  void topicFollow(
      String name, Object receiver, NotificationCallback callback) {
    final tf = Follower.topicFollower(name, receiver, callback);
    _follow(tf);
  }

  /// Unfollow this notification name, no matter from who
  void topicUnfollow(String name, Object receiver) {
    final tf = Follower.topicFollower(name, receiver, _nopCallback);
    _unfollow(tf);
  }

  /// Follow all notifications from a certain object
  void fanFollow(
      Object sender, Object receiver, NotificationCallback callback) {
    final ff = Follower.fanFollower(sender, receiver, callback);
    _follow(ff);
  }

  void fanUnfollow(Object sender, Object receiver) {
    final ff = Follower.fanFollower(sender, receiver, _nopCallback);
    _unfollow(ff);
  }

  /// Follows only a specific notification from a given sender
  void specificFollow(String name, Object sender, Object receiver,
      NotificationCallback callback) {
    final sf = Follower.compositeFollower(name, sender, receiver, callback);
    _follow(sf);
  }

  void specificUnfollow(String name, Object sender, Object receiver) {
    final sf = Follower.compositeFollower(name, sender, receiver, _nopCallback);
    _unfollow(sf);
  }

  // Send
  void send(Notification notification) {
    _queue.forEach((recipient) {
      if (recipient.isFollowing(notification)) {
        _send(recipient, notification);
      }
    });
  }

  void sendLater(Notification notification) {
    _queue.forEach((recipient) {
      if (recipient.isFollowing(notification)) {
        _send(recipient, notification, isDelayed: true);
      }
    });
  }

  void _send(Follower recipient, Notification notification,
      {bool isDelayed = false}) {
    if (isDelayed) {
      Timer.run(() {
        recipient.notify(notification);
      });
    } else {
      recipient.notify(notification);
    }
  }

  /// Removes all followers from the list. Used for testing mostly.
  @visibleForTesting
  void zap() {
    _queue = [];
  }

  /// NOP callback used for the unfollows. There's no need for the user to provide
  /// the callback on the unfollow as it's not used for identity of the Follower.
  void _nopCallback(Notification n) {}
}
