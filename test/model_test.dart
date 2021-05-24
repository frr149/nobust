import 'package:nobust/nobust.dart';
import 'package:test/test.dart';

class CountingObserver extends Observer {
  int _totalNotifications = 0;
  int get totalNotifications => _totalNotifications;

  @override
  void onModelChange(Notification notification) {
    _totalNotifications += 1;
  }
}

class CountingModel extends Model {
  int _tally = 0;
  int get tally => _tally;
  set tally(int newVal) {
    _tally = tally;
    notify();
  }
}

void main() {
  setUp(() {});

  tearDown(() {
    NotificationCenter.defaultCenter.zap();
  });

  group('model', () {
    test('all models have different changeNotificationName', () {
      expect(Model().changeNotificationName != Model().changeNotificationName,
          isTrue);

      expect(
          CountingModel().changeNotificationName !=
              CountingModel().changeNotificationName,
          isTrue);
    });

    test('notify sends single notification', () {
      final counter = CountingModel();
      final observer = CountingObserver();
      observer.follow(counter);

      expect(observer.totalNotifications, 0);
      counter.tally = 42;
      expect(observer.totalNotifications, 1);
    });
  });
}
