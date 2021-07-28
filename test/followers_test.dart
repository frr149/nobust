import 'package:notice_service/notices.dart';
import 'package:notice_service/src/notice_center.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  late NoticeCounter receiver1;
  late NoticeCounter receiver2;
  late NoticeCounter receiver3;

  late TestNotifier sender1;
  late TestNotifier sender2;

  setUp(() {
    sender1 = TestNotifier.sized(42);
    sender2 = TestNotifier.sized(2);
    receiver1 = NoticeCounter();
    receiver2 = NoticeCounter();
    receiver3 = NoticeCounter();

    NoticeCenter.defaultCenter
        .followNoticeName(kNoticeName1, receiver1, receiver1.inc);

    NoticeCenter.defaultCenter.followSender(sender1, receiver3, receiver3.inc);

    NoticeCenter.defaultCenter
        .follow(kNoticeName1, sender2, receiver1, receiver1.inc);

    NoticeCenter.defaultCenter
        .follow(kNoticeName1, sender1, receiver2, receiver2.inc);
  });

  tearDown(() {
    NoticeCenter.defaultCenter.zap();
  });

  group("send & receive", () {
    test("send kNotice1 from sender1", () {
      // send
      sender1.send(kNoticeName1);

      // expectations
      expect(NoticeCenter.defaultCenter.length, 4);
      expect(receiver1.count, 1);
      expect(receiver2.count, 1);
      expect(receiver3.count, 1);
    });

    test("sender2 sends kNotice2", () {
      sender2.send(kNoticeName2);

      expect(receiver1.count, 0);
      expect(receiver2.count, 0);
      expect(receiver3.count, 0);
    });

    test("sender2 sends kNotice1", () {
      sender2.send(kNoticeName1);

      expect(receiver1.count, 2);
      expect(receiver2.count, 0);
      expect(receiver3.count, 0);
    });
  });
}
