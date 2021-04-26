import 'package:nobust/nobust.dart';
import 'package:nobust/src/notification_center.dart';
import 'package:test/test.dart';

class _NotificationCounter {
  int _count = 0;
  int get count => _count;

  void inc(Notification notification) => _count++;
}

const String kNotificationName1 =
    "Your bones don't break, mine do. That's clear.";
const String kNotificationName2 =
    'The path of the righteous man is beset on all sides';
const int dummyReceiver = 42;
void callback(Notification n) {}

void main() {
  late _NotificationCounter counter;
  late Notification notification;
  late _NotificationCounter counter2;
  late Notification notification2;
  late Follower f1;
  late Follower f2;
  late Follower f3;
  late Follower f4;
  late Follower f5;

  setUp(() {
    // Follower
    f1 = Follower(kNotificationName1, dummyReceiver, callback);
    f2 = Follower(kNotificationName1, dummyReceiver, callback);
    f3 = Follower(kNotificationName2, dummyReceiver, callback);
    f4 = Follower(kNotificationName2, f1, callback);
    f5 = Follower(kNotificationName1, f1, callback);

    counter = _NotificationCounter();
    notification = Notification(name: kNotificationName1);

    counter2 = _NotificationCounter();
    notification2 = Notification(name: kNotificationName2);
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
            .follow(kNotificationName1, counter, counter.inc);
      }
      expect(NotificationCenter.defaultCenter.length, 1);
    });

    test("add n times different follower, length es n", () {
      const int n = 42;
      for (int i = 0; i < n; i++) {
        _NotificationCounter c = _NotificationCounter();
        NotificationCenter.defaultCenter.follow(kNotificationName1, c, c.inc);
      }
      expect(NotificationCenter.defaultCenter.length, n);
    });

    test("after zapping, length es 0", () {
      const int n = 42;
      for (int i = 0; i < n; i++) {
        _NotificationCounter c = _NotificationCounter();
        NotificationCenter.defaultCenter.follow(kNotificationName1, c, c.inc);
      }
      NotificationCenter.defaultCenter.zap();
      expect(NotificationCenter.defaultCenter.length, 0);
    });
  });

  group("Follower helper class", () {
    test("creation", () {
      expect(Follower(kNotificationName1, dummyReceiver, callback), isNotNull);
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
          .follow(kNotificationName1, counter, counter.inc);
      NotificationCenter.defaultCenter.send(notification);
      expect(counter.count, 1);
    });

    test('Sending the wrong notification is a NOP', () {
      NotificationCenter.defaultCenter
          .follow(kNotificationName1, counter, counter.inc);

      NotificationCenter.defaultCenter.send(Notification(name: 'notInTheList'));

      expect(counter.count, 0);
    });

    test('Sending without first following is a NOP', () {
      NotificationCenter.defaultCenter.send(notification);
      expect(counter.count, 0);
    });

    test('Following many times is the same as following once', () {
      NotificationCenter.defaultCenter
          .follow(kNotificationName1, counter, counter.inc);

      NotificationCenter.defaultCenter
          .follow(kNotificationName1, counter, counter.inc);

      NotificationCenter.defaultCenter.send(notification);
      expect(counter.count, 1);
    });

    test('Same follower and 2 notifications, gets 2', () {
      NotificationCenter.defaultCenter
          .follow(kNotificationName1, counter, counter.inc);

      NotificationCenter.defaultCenter
          .follow(kNotificationName2, counter, counter.inc);

      NotificationCenter.defaultCenter.send(notification);
      NotificationCenter.defaultCenter.send(notification2);
      expect(counter.count, 2);
    });

    test('Two followers and 2 notifications, each gets 1', () {
      NotificationCenter.defaultCenter
          .follow(kNotificationName1, counter, counter.inc);

      NotificationCenter.defaultCenter
          .follow(kNotificationName2, counter2, counter2.inc);

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
