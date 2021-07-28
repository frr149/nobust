import 'dart:async';

import 'package:meta/meta.dart';
import 'package:notice_service/src/notice.dart';
import 'package:notice_service/src/followers.dart';

class NoticeCenter {
  int get length => _queue.length;

  // Singleton
  NoticeCenter._defaultCenter();
  static final defaultCenter = NoticeCenter._defaultCenter();

  // NoticeQueue
  Followers _queue = [];

  // adds / removes followers to the queue
  void _follow(Follower follower) {
    if (!_queue.contains(follower)) {
      _queue.add(follower);
    }
  }

  void _unfollow(Follower follower) {
    _queue.remove(follower);
  }

  /// Follow every single Notice with htis name, no matter who sends it
  void followNoticeName(String name, Object receiver, NoticeCallback callback) {
    final tf = Follower.topicFollower(name, receiver, callback);
    _follow(tf);
  }

  /// Unfollow this Notice name, no matter from who
  void unfollowNoticeName(String name, Object receiver) {
    final tf = Follower.topicFollower(name, receiver, _nopCallback);
    _unfollow(tf);
  }

  /// Follow all Notices from a certain object
  void followSender(Object sender, Object receiver, NoticeCallback callback) {
    final ff = Follower.fanFollower(sender, receiver, callback);
    _follow(ff);
  }

  void unfollowSender(Object sender, Object receiver) {
    final ff = Follower.fanFollower(sender, receiver, _nopCallback);
    _unfollow(ff);
  }

  /// Follows only a specific Notice from a given sender
  void follow(
      String name, Object sender, Object receiver, NoticeCallback callback) {
    final sf = Follower.compositeFollower(name, sender, receiver, callback);
    _follow(sf);
  }

  void unfollow(String name, Object sender, Object receiver) {
    final sf = Follower.compositeFollower(name, sender, receiver, _nopCallback);
    _unfollow(sf);
  }

  // Send
  void send(Notice Notice) {
    _queue.forEach((recipient) {
      if (recipient.isFollowing(Notice)) {
        _send(recipient, Notice);
      }
    });
  }

  void sendLater(Notice Notice) {
    _queue.forEach((recipient) {
      if (recipient.isFollowing(Notice)) {
        _send(recipient, Notice, isDelayed: true);
      }
    });
  }

  void _send(Follower recipient, Notice Notice, {bool isDelayed = false}) {
    if (isDelayed) {
      scheduleMicrotask(() {
        recipient.notify(Notice);
      });
    } else {
      recipient.notify(Notice);
    }
  }

  /// Removes all followers from the list. Used for testing mostly.
  @visibleForTesting
  void zap() {
    _queue = [];
  }

  /// NOP callback used for the unfollows. There's no need for the user to provide
  /// the callback on the unfollow as it's not used for identity of the Follower.
  void _nopCallback(Notice n) {}
}
