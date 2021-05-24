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

  group('Observer', () {
    test('All null-observers are identical', () {
      final n1 = NullObserver.shared;
      final n2 = NullObserver.shared;
      expect(identical(n1, n2), isTrue);
    });

    test('Null observers arenty added to the queue', () {
      final m = CountingModel();
      final o = CountingObserver();

      // All models start uoput with the null observer
      expect(m.observer == NullObserver.shared, true);
      // Null observers don't add to the queue
      expect(NotificationCenter.defaultCenter.length, 0);
      m.observer = o;
      // Non-null observers do add to the queue
      expect(m.observer != NullObserver.shared, isTrue);
      expect(m.observer, o);
      expect(NotificationCenter.defaultCenter.length, 1);
    });
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
      counter.observer = observer;

      expect(observer.totalNotifications, 0);
      counter.tally = 42;
      expect(observer.totalNotifications, 1);
    });
  });
}
