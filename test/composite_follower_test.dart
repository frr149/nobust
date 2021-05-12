import 'package:nobust/nobust.dart';
import 'package:nobust/src/notification_center.dart';
import 'package:nobust/src/followers.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  late Follower sf1;
  late Follower sf2;
  late Follower sf3;
  late Model model;
  const otherReceiver = 675;

  setUp(() {
    model = Model();
    sf1 = Follower.compositeFollower(
        kNotificationName1, model, dummyReceiver, callback);
    sf2 = Follower.compositeFollower(
        kNotificationName1, model, dummyReceiver, callback);
    sf3 = Follower.compositeFollower(
        kNotificationName2, model, otherReceiver, callback);
  });
  tearDown(() {
    NotificationCenter.defaultCenter.zap();
  });

  group("creation", () {
    test("can create", () {
      expect(
          Follower.compositeFollower(
              kNotificationName2, model, dummyReceiver, callback),
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
      final m = Model();
      final n = NotificationCounter();

      for (int i = 0; i < 20; i++) {
        NotificationCenter.defaultCenter
            .specificFollow(kNotificationName1, m, n, n.inc);
      }
      expect(NotificationCenter.defaultCenter.length, 1);

      NotificationCenter.defaultCenter
          .specificUnfollow(kNotificationName1, m, n);
      expect(NotificationCenter.defaultCenter.length, 0);
    });
  });

  test("Adding n different followers, length is n", () {
    final n = NotificationCounter();
    const int size = 99;

    for (int i = 0; i < size; i++) {
      final m = Model.sized(i);
      NotificationCenter.defaultCenter
          .specificFollow(kNotificationName1, m, n, n.inc);
    }

    expect(NotificationCenter.defaultCenter.length, size);
  });
}
