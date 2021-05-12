import 'package:nobust/nobust.dart';
import 'package:nobust/src/notification_center.dart';
import 'package:nobust/src/followers.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  late NotificationCounter receiver1;
  late NotificationCounter receiver2;
  late NotificationCounter receiver3;

  late Model sender1;
  late Model sender2;

  setUp(() {
    sender1 = Model.sized(42);
    sender2 = Model.sized(2);
    receiver1 = NotificationCounter();
    receiver2 = NotificationCounter();
    receiver3 = NotificationCounter();

    NotificationCenter.defaultCenter
        .topicFollow(kNotificationName1, receiver1, receiver1.inc);

    NotificationCenter.defaultCenter
        .fanFollow(sender1, receiver3, receiver3.inc);

    NotificationCenter.defaultCenter
        .specificFollow(kNotificationName1, sender2, receiver1, receiver1.inc);

    NotificationCenter.defaultCenter
        .specificFollow(kNotificationName1, sender1, receiver2, receiver2.inc);
  });

  tearDown(() {
    NotificationCenter.defaultCenter.zap();
  });

  group("send & receive", () {
    test("send kNotification1 from sender1", () {
      // send
      sender1.send(kNotificationName1);

      // expectations
      expect(NotificationCenter.defaultCenter.length, 4);
      expect(receiver1.count, 1);
      expect(receiver2.count, 1);
      expect(receiver3.count, 1);
    });

    test("sender2 sends kNotification2", () {
      sender2.send(kNotificationName2);

      expect(receiver1.count, 0);
      expect(receiver2.count, 0);
      expect(receiver3.count, 0);
    });

    test("sender2 sends kNotification1", () {
      sender2.send(kNotificationName1);

      expect(receiver1.count, 2);
      expect(receiver2.count, 0);
      expect(receiver3.count, 0);
    });
  });
}
