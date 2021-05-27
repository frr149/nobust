import 'package:notifications/notifications.dart';
import 'package:test/test.dart';

class ChangeCounter<Emitter extends ChangeEmitter<Emitter>>
    with ChangeReceiver<Emitter> {
  int _count = 0;
  int get count => _count;

  ChangeCounter(Emitter emitter) {
    host = emitter;
    start(() {
      _count++;
    });
  }
}

class Person with ChangeEmitter<Person> {
  late String _name;
  String get name => _name;
  set name(String newval) {
    changeState(() {
      _name = newval;
    });
  }

  Person(String name) : _name = name {
    model = this;
  }
}

class Foo with ChangeEmitter<Foo> {
  late int _level;
  int get level => _level;
  set level(int newVal) {
    changeState(() {
      _level = newVal;
      stage = _level + 42; // will cause re-entrant call
    });
  }

  late int _stage; // depends on level
  int get stage => _stage;
  set stage(int newVal) {
    changeState(() {
      _stage = newVal;
    });
  }

  Foo(int level, int stage)
      : _level = level,
        _stage = stage {
    model = this;
  }
}

void main() {
  setUp(() {});

  tearDown(() {
    NotificationCenter.defaultCenter.zap();
  });

  group('model', () {
    test('all models have different changeNotificationName', () {
      expect(
          Person('Lucas').changeNotificationName !=
              Person('Lucas').changeNotificationName,
          isTrue);

      expect(
          Foo(0, 0).changeNotificationName !=
              Person('Pozí').changeNotificationName,
          isTrue);
    });

    test('changing observed fields, sends notification', () {
      final vader = Person('Anakin');
      final counter = ChangeCounter(vader);

      expect(counter.count, 0);
      vader.name = 'Darth Vader';
      expect(counter.count, 1);
      counter.stop();
      vader.name = 'Manolo';
      expect(counter.count, 1);
    });

    test('re-entrant calls to notification only send 1', () {
      final f = Foo(0, 0);
      final obs = ChangeCounter(f);

      f.level = 42;
      expect(obs.count, 1);
      f.level = 9;
      expect(obs.count, 2);
      obs.stop();
      f.level = 21;
      expect(obs.count, 2);
    });
  });
}
