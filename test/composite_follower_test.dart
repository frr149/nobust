import 'package:notice_service/notice_service.dart';
import 'package:notice_service/src/notice_center.dart';
import 'package:notice_service/src/followers.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  late Follower sf1;
  late Follower sf2;
  late Follower sf3;
  late TestNotifier notifier;
  const otherReceiver = 675;

  setUp(() {
    notifier = TestNotifier();
    sf1 = Follower.compositeFollower(
        kNoticeName1, notifier, dummyReceiver, callback);
    sf2 = Follower.compositeFollower(
        kNoticeName1, notifier, dummyReceiver, callback);
    sf3 = Follower.compositeFollower(
        kNoticeName2, notifier, otherReceiver, callback);
  });
  tearDown(() {
    NoticeCenter.defaultCenter.zap();
  });

  group("creation", () {
    test("can create", () {
      expect(
          Follower.compositeFollower(
              kNoticeName2, notifier, dummyReceiver, callback),
          isNotNull);
    });
  });

  group("equality", () {
    test("equivalent objects", () {
      expect(sf1, sf1);
      expect(sf2, sf2);
      expect(sf1, sf2);

      expect(sf1 != sf3, isTrue);
      expect(sf2 != sf3, isTrue);
    });

    test("equivalent objects have the same hashCode", () {
      expect(sf1.hashCode, sf1.hashCode);
      expect(sf2.hashCode, sf1.hashCode);
    });
  });

  group("Adding ", () {
    test("Adding the same follower is a NOP", () {
      final m = TestNotifier();
      final n = NoticeCounter();

      for (int i = 0; i < 20; i++) {
        NoticeCenter.defaultCenter.follow(kNoticeName1, m, n, n.inc);
      }
      expect(NoticeCenter.defaultCenter.length, 1);

      NoticeCenter.defaultCenter.unfollow(kNoticeName1, m, n);
      expect(NoticeCenter.defaultCenter.length, 0);
    });
  });

  test("Adding n different followers, length is n", () {
    final n = NoticeCounter();
    const int size = 99;

    for (int i = 0; i < size; i++) {
      final m = TestNotifier.sized(i);
      NoticeCenter.defaultCenter.follow(kNoticeName1, m, n, n.inc);
    }

    expect(NoticeCenter.defaultCenter.length, size);
  });
}
