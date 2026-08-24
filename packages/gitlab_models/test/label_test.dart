import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  group('Label.listFromJson', () {
    test('parses objects with colours', () {
      final labels = Label.listFromJson(const [
        {'name': 'bug', 'color': '#d73a4a', 'text_color': '#ffffff'},
      ]);
      expect(labels.single.name, 'bug');
      expect(labels.single.color, '#d73a4a');
      expect(labels.single.textColor, '#ffffff');
    });

    test('parses bare strings as names without a colour', () {
      final labels = Label.listFromJson(const ['bug', 'android']);
      expect(labels.map((l) => l.name), ['bug', 'android']);
      expect(labels.first.color, isNull);
    });

    test('returns empty for a non-list', () {
      expect(Label.listFromJson(null), isEmpty);
    });
  });
}
