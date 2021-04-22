import 'package:nobust/nobust.dart';
import 'package:test/test.dart';

void main() {
  group("creation", () {
    test('singleton', () {
      expect(NotificationCenter.defaultCenter, isNotNull);
    });
  });
}
