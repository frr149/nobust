import 'package:nobust/nobust.dart';
import 'package:test/test.dart';

void main() {
  const kName = 'yeahMagnets!';
  const kSender = 42;
  const kPayload = [42];

  late Notification n1;
  late Notification n2;
  late Notification n3;
  late Notification n4;
  late Notification n5;
  setUp(() {
    n1 = Notification(name: kName, sender: kSender);
    n2 = Notification(name: kName, sender: kSender);
    n3 = Notification(name: kName, sender: kSender, payload: kPayload);
    n4 = Notification(name: kName, sender: kSender, payload: kPayload);
    n5 = Notification(name: kName, sender: kSender, payload: kPayload);
  });

  group('creation & access', () {
    test('create', () {
      expect(Notification(name: kName, sender: kSender), isNotNull);
      expect(Notification(name: kName, sender: kSender), isNotNull);
      expect(Notification(name: kName, sender: kSender, payload: kPayload),
          isNotNull);
    });
  });

  group("value", () {
    test('equality', () {
      expect(n1, n1);
      expect(n1, Notification(name: kName, sender: kSender));

      expect(n4, Notification(name: kName, sender: kSender, payload: kPayload));
      expect(n3, n3);

      expect(n1 == n3, isFalse);
      expect(n2 == n3, isFalse);
    });

    test("equal objects must have equal hashes", () {
      expect(n5, n4);
      expect(n5.hashCode == n4.hashCode, isTrue);
    });
  });
}
