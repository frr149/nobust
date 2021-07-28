import 'package:notice_service/notices.dart';
import 'package:notice_service/src/followers.dart';
import 'package:notice_service/src/notice_center.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  const String dummySender = "dummy";
  late NoticeCounter counter;
  late Notice notice;
  late NoticeCounter counter2;
  late Notice notice2;
  late TopicFollower f1;
  late TopicFollower f2;
  late TopicFollower f3;
  late TopicFollower f4;
  late TopicFollower f5;

  setUp(() {
    // Follower
    f1 = TopicFollower(kNoticeName1, dummyReceiver, callback);
    f2 = TopicFollower(kNoticeName1, dummyReceiver, callback);
    f3 = TopicFollower(kNoticeName2, dummyReceiver, callback);
    f4 = TopicFollower(kNoticeName2, f1, callback);
    f5 = TopicFollower(kNoticeName1, f1, callback);

    counter = NoticeCounter();
    notice = Notice(name: kNoticeName1, sender: dummySender);

    counter2 = NoticeCounter();
    notice2 = Notice(name: kNoticeName2, sender: dummySender);
  });

  tearDown(() {
    NoticeCenter.defaultCenter.zap();
  });

  group("creation", () {
    test('singleton', () {
      expect(NoticeCenter.defaultCenter, isNotNull);
    });
  });

  group("Length", () {
    test("length starts at zero", () {
      expect(NoticeCenter.defaultCenter.length, 0);
    });

    test("add n times same follower, length es 1", () {
      const int n = 42;
      for (int i = 0; i < n; i++) {
        NoticeCenter.defaultCenter
            .followNoticeName(kNoticeName1, counter, counter.inc);
      }
      expect(NoticeCenter.defaultCenter.length, 1);
    });

    test("add n times different follower, length es n", () {
      const int n = 42;
      for (int i = 0; i < n; i++) {
        final NoticeCounter c = NoticeCounter();
        NoticeCenter.defaultCenter.followNoticeName(kNoticeName1, c, c.inc);
      }
      expect(NoticeCenter.defaultCenter.length, n);
    });

    test("after zapping, length es 0", () {
      const int n = 42;
      for (int i = 0; i < n; i++) {
        final NoticeCounter c = NoticeCounter();
        NoticeCenter.defaultCenter.followNoticeName(kNoticeName1, c, c.inc);
      }
      NoticeCenter.defaultCenter.zap();
      expect(NoticeCenter.defaultCenter.length, 0);
    });
  });

  group("Follower helper class", () {
    test("creation", () {
      expect(TopicFollower(kNoticeName1, dummyReceiver, callback), isNotNull);
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

    test('follow and send gets 1 Notice', () {
      NoticeCenter.defaultCenter
          .followNoticeName(kNoticeName1, counter, counter.inc);
      NoticeCenter.defaultCenter.send(notice);
      expect(counter.count, 1);
    });

    test('Sending the wrong Notice is a NOP', () {
      NoticeCenter.defaultCenter
          .followNoticeName(kNoticeName1, counter, counter.inc);

      NoticeCenter.defaultCenter
          .send(Notice(name: 'notInTheList', sender: dummySender));

      expect(counter.count, 0);
    });

    test('Sending without first following is a NOP', () {
      NoticeCenter.defaultCenter.send(notice);
      expect(counter.count, 0);
    });

    test('Following many times is the same as following once', () {
      NoticeCenter.defaultCenter
          .followNoticeName(kNoticeName1, counter, counter.inc);

      NoticeCenter.defaultCenter
          .followNoticeName(kNoticeName1, counter, counter.inc);

      NoticeCenter.defaultCenter.send(notice);
      expect(counter.count, 1);
    });

    test('Same follower and 2 Notices, gets 2', () {
      NoticeCenter.defaultCenter
          .followNoticeName(kNoticeName1, counter, counter.inc);

      NoticeCenter.defaultCenter
          .followNoticeName(kNoticeName2, counter, counter.inc);

      NoticeCenter.defaultCenter.send(notice);
      NoticeCenter.defaultCenter.send(notice2);
      expect(counter.count, 2);
    });

    test('Two followers and 2 Notices, each gets 1', () {
      NoticeCenter.defaultCenter
          .followNoticeName(kNoticeName1, counter, counter.inc);

      NoticeCenter.defaultCenter
          .followNoticeName(kNoticeName2, counter2, counter2.inc);

      expect(counter.count, 0);
      expect(counter2.count, 0);

      NoticeCenter.defaultCenter.send(notice);

      expect(counter.count, 1);
      // Aqui está el fallo, counter2 recibe una notificación que no le corresponde.  O se ha añadido donde no debe, o el método send está mal
      expect(counter2.count, 0);

      NoticeCenter.defaultCenter.send(notice2);

      expect(NoticeCenter.defaultCenter.length, 2);

      expect(counter.count, 1);
      expect(counter2.count, 1);
    });
  });
}
