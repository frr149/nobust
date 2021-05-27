import 'package:notifications/notifications.dart';

const String kNotificationName1 =
    "Your bones don't break, mine do. That's clear.";
const String kNotificationName2 =
    'The path of the righteous man is beset on all sides';
const int dummyReceiver = 42;

void callback(Notification n) {}

// Receives notifications
class NotificationCounter {
  int _count = 0;
  int get count => _count;

  void inc(Notification notification) => _count++;
}

//Sends notifications
class TestNotifier {
  int i = 0;

  TestNotifier();
  TestNotifier.sized(this.i);

  void send(String name) {
    final Notification n = Notification(name: name, sender: this);
    NotificationCenter.defaultCenter.send(n);
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
