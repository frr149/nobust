import 'package:notice_service/notice_service.dart';

const String kNoticeName1 = "Your bones don't break, mine do. That's clear.";
const String kNoticeName2 =
    'The path of the righteous man is beset on all sides';
const int dummyReceiver = 42;

void callback(Notice n) {}

// Receives Notices
class NoticeCounter {
  int _count = 0;
  int get count => _count;

  void inc(Notice notice) => _count++;
}

//Sends Notices
class TestNotifier {
  int i = 0;

  TestNotifier();
  TestNotifier.sized(this.i);

  void send(String name) {
    final Notice n = Notice(name: name, sender: this);
    NoticeCenter.defaultCenter.send(n);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else {
      return other is TestNotifier && i == other.i;
    }
  }

  @override
  // TODO: implement hashCode
  int get hashCode => i.hashCode;
}
