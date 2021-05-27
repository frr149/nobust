import 'package:notifications/notifications.dart';
import 'package:notifications/src/notification_center.dart';
import 'package:notifications/src/followers.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  late Follower tf1;
  late Follower tf2;
  late Follower tf3;
  late TestNotifier model;

  setUp(() {
    model = TestNotifier();
    tf1 = Follower.fanFollower(model, dummyReceiver, callback);
    tf2 = Follower.fanFollower(model, dummyReceiver, callback);
    tf3 = Follower.fanFollower(42, "receiver", callback);
  });
  tearDown(() {
    NotificationCenter.defaultCenter.zap();
  });

  group("creation & equality", () {
    test("Must not be null", () {
      expect(Follower.fanFollower(model, dummyReceiver, callback), isNotNull);
    });

    test("equality & hash", () {
      expect(tf1, tf2);

      expect(tf2 == Follower.fanFollower(model, "42", callback), isFalse);
      expect(tf1 == tf3, isFalse);
    });

    test("equal objects should have equal hasCodes", () {
      expect(tf1.hashCode, tf2.hashCode);
      expect(tf1.hashCode == tf3.hashCode, isFalse);
    });
  });

  group("Adding several times ", () {
    test("Adding the same follower is a NOP", () {
      final m = TestNotifier();
      final n = NotificationCounter();

      for (int i = 0; i < 20; i++) {
        NotificationCenter.defaultCenter.fanFollow(m, n, n.inc);
      }
      expect(NotificationCenter.defaultCenter.length, 1);

      NotificationCenter.defaultCenter.fanUnfollow(m, n);
      expect(NotificationCenter.defaultCenter.length, 0);
    });
  });

  test("Adding n different followers, length is n", () {
    final n = NotificationCounter();
    const int size = 99;

    for (int i = 0; i < size; i++) {
      final m = TestNotifier.sized(i);
      NotificationCenter.defaultCenter.fanFollow(m, n, n.inc);
    }

    expect(NotificationCenter.defaultCenter.length, size);
  });

  group("sending", () {
    test("sender send n notifications, receiver gets n", () {
      final sender = TestNotifier();
      final receiver = NotificationCounter();
      const int n = 150;

      NotificationCenter.defaultCenter
          .fanFollow(sender, receiver, receiver.inc);

      for (int i = 0; i < n; i++) {
        sender.send('Notification #$i');
      }
      expect(receiver.count, n);
    });
  });
}
