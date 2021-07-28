import 'package:notice_service/notices.dart';
import 'package:test/test.dart';

void main() {
  const kName = 'yeahMagnets!';
  const kSender = 42;
  const kPayload = [42];

  late Notice n1;
  late Notice n2;
  late Notice n3;
  late Notice n4;
  late Notice n5;
  setUp(() {
    n1 = Notice(name: kName, sender: kSender);
    n2 = Notice(name: kName, sender: kSender);
    n3 = Notice(name: kName, sender: kSender, payload: kPayload);
    n4 = Notice(name: kName, sender: kSender, payload: kPayload);
    n5 = Notice(name: kName, sender: kSender, payload: kPayload);
  });

  group('creation & access', () {
    test('create', () {
      expect(Notice(name: kName, sender: kSender), isNotNull);
      expect(Notice(name: kName, sender: kSender), isNotNull);
      expect(
          Notice(name: kName, sender: kSender, payload: kPayload), isNotNull);
    });
  });

  group("value", () {
    test('equality', () {
      expect(n1, n1);
      expect(n1, Notice(name: kName, sender: kSender));

      expect(n4, Notice(name: kName, sender: kSender, payload: kPayload));
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
