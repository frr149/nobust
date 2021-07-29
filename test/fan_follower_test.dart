import 'package:notice_service/notice_service.dart';
import 'package:notice_service/src/notice_center.dart';
import 'package:notice_service/src/followers.dart';
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
    NoticeCenter.defaultCenter.zap();
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
      final n = NoticeCounter();

      for (int i = 0; i < 20; i++) {
        NoticeCenter.defaultCenter.followSender(m, n, n.inc);
      }
      expect(NoticeCenter.defaultCenter.length, 1);

      NoticeCenter.defaultCenter.unfollowSender(m, n);
      expect(NoticeCenter.defaultCenter.length, 0);
    });
  });

  test("Adding n different followers, length is n", () {
    final n = NoticeCounter();
    const int size = 99;

    for (int i = 0; i < size; i++) {
      final m = TestNotifier.sized(i);
      NoticeCenter.defaultCenter.followSender(m, n, n.inc);
    }

    expect(NoticeCenter.defaultCenter.length, size);
  });

  group("sending", () {
    test("sender send n Notices, receiver gets n", () {
      final sender = TestNotifier();
      final receiver = NoticeCounter();
      const int n = 150;

      NoticeCenter.defaultCenter.followSender(sender, receiver, receiver.inc);

      for (int i = 0; i < n; i++) {
        sender.send('Notice #$i');
      }
      expect(receiver.count, n);
    });
  });
}
