import 'package:notifications/notifications.dart';
import 'package:notifications/src/followers.dart';
import 'package:notifications/src/notification_center.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  const String dummySender = "dummy";
  late NotificationCounter counter;
  late Notification notification;
  late NotificationCounter counter2;
  late Notification notification2;
  late TopicFollower f1;
  late TopicFollower f2;
  late TopicFollower f3;
  late TopicFollower f4;
  late TopicFollower f5;

  setUp(() {
    // Follower
    f1 = TopicFollower(kNotificationName1, dummyReceiver, callback);
    f2 = TopicFollower(kNotificationName1, dummyReceiver, callback);
    f3 = TopicFollower(kNotificationName2, dummyReceiver, callback);
    f4 = TopicFollower(kNotificationName2, f1, callback);
    f5 = TopicFollower(kNotificationName1, f1, callback);

    counter = NotificationCounter();
    notification = Notification(name: kNotificationName1, sender: dummySender);

    counter2 = NotificationCounter();
    notification2 = Notification(name: kNotificationName2, sender: dummySender);
  });

  tearDown(() {
    NotificationCenter.defaultCenter.zap();
  });

  group("creation", () {
    test('singleton', () {
      expect(NotificationCenter.defaultCenter, isNotNull);
    });
  });

  group("Length", () {
    test("length starts at zero", () {
      expect(NotificationCenter.defaultCenter.length, 0);
    });

    test("add n times same follower, length es 1", () {
      const int n = 42;
      for (int i = 0; i < n; i++) {
        NotificationCenter.defaultCenter
            .followNotificationName(kNotificationName1, counter, counter.inc);
      }
      expect(NotificationCenter.defaultCenter.length, 1);
    });

    test("add n times different follower, length es n", () {
      const int n = 42;
      for (int i = 0; i < n; i++) {
        final NotificationCounter c = NotificationCounter();
        NotificationCenter.defaultCenter
            .followNotificationName(kNotificationName1, c, c.inc);
      }
      expect(NotificationCenter.defaultCenter.length, n);
    });

    test("after zapping, length es 0", () {
      const int n = 42;
      for (int i = 0; i < n; i++) {
        final NotificationCounter c = NotificationCounter();
        NotificationCenter.defaultCenter
            .followNotificationName(kNotificationName1, c, c.inc);
      }
      NotificationCenter.defaultCenter.zap();
      expect(NotificationCenter.defaultCenter.length, 0);
    });
  });

  group("Follower helper class", () {
    test("creation", () {
      expect(TopicFollower(kNotificationName1, dummyReceiver, callback),
          isNotNull);
    });

    test("Equality & hash", () {
      expect(f4 == f1, isFalse); // different name and different receiver
      expect(f1 == f5, isFalse); // same name, different receiver
      expect(f1 == f3, isFalse); // different name same receiver
      expect(f1, f2); // same name , same receiver

      expect(f1, f1); // identical objects
      expect(f2, f2); // identical objects
      expect(f3, f3); // identical objects
      expect(f4, f4); // identical objects

      expect(f1.hashCode, f2.hashCode); // equal objects must have equal hascode
      expect(f4.hashCode, f4.hashCode);
    });
  });

  group('follow and unfollow', () {
    test('Fresh counter starts at 0', () {
      expect(counter.count, 0);
    });

    test('follow and send gets 1 notification', () {
      NotificationCenter.defaultCenter
          .followNotificationName(kNotificationName1, counter, counter.inc);
      NotificationCenter.defaultCenter.send(notification);
      expect(counter.count, 1);
    });

    test('Sending the wrong notification is a NOP', () {
      NotificationCenter.defaultCenter
          .followNotificationName(kNotificationName1, counter, counter.inc);

      NotificationCenter.defaultCenter
          .send(Notification(name: 'notInTheList', sender: dummySender));

      expect(counter.count, 0);
    });

    test('Sending without first following is a NOP', () {
      NotificationCenter.defaultCenter.send(notification);
      expect(counter.count, 0);
    });

    test('Following many times is the same as following once', () {
      NotificationCenter.defaultCenter
          .followNotificationName(kNotificationName1, counter, counter.inc);

      NotificationCenter.defaultCenter
          .followNotificationName(kNotificationName1, counter, counter.inc);

      NotificationCenter.defaultCenter.send(notification);
      expect(counter.count, 1);
    });

    test('Same follower and 2 notifications, gets 2', () {
      NotificationCenter.defaultCenter
          .followNotificationName(kNotificationName1, counter, counter.inc);

      NotificationCenter.defaultCenter
          .followNotificationName(kNotificationName2, counter, counter.inc);

      NotificationCenter.defaultCenter.send(notification);
      NotificationCenter.defaultCenter.send(notification2);
      expect(counter.count, 2);
    });

    test('Two followers and 2 notifications, each gets 1', () {
      NotificationCenter.defaultCenter
          .followNotificationName(kNotificationName1, counter, counter.inc);

      NotificationCenter.defaultCenter
          .followNotificationName(kNotificationName2, counter2, counter2.inc);

      expect(counter.count, 0);
      expect(counter2.count, 0);

      NotificationCenter.defaultCenter.send(notification);

      expect(counter.count, 1);
      // Aqui está el fallo, counter2 recibe una notificación que no le corresponde.  O se ha añadido donde no debe, o el método send está mal
      expect(counter2.count, 0);

      NotificationCenter.defaultCenter.send(notification2);

      expect(NotificationCenter.defaultCenter.length, 2);

      expect(counter.count, 1);
      expect(counter2.count, 1);
    });
  });
}
