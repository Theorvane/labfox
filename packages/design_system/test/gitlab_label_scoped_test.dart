import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Scoped labels, as GitLab renders them.
///
/// Measured from gitlab.com's own markup rather than guessed. A scoped label is
/// one whose name contains `::` — `devops::security platform` — and GitLab
/// splits it into two segments: the scope on the label's colour, the value on a
/// muted ground beside it.
///
/// This is not decoration. Scoped labels are **mutually exclusive within their
/// scope** — an issue can be `workflow::in dev` or `workflow::in review`, never
/// both — and the split is what tells a reader that `devops` is a dimension and
/// `security platform` is its current value. Flattening it into one pill throws
/// that away, which is what this app was doing.
///
/// A single colon is *not* a scope. `Category:Secrets Manager` is an ordinary
/// label whose name happens to contain a colon, and gitlab.com renders it as
/// one plain pill. Splitting on `:` would break those.
Widget _harness(Widget child) => MaterialApp(
  theme: LabFoxTheme.light,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('a scoped label renders as two segments', (tester) async {
    await tester.pumpWidget(
      _harness(
        const GitLabLabel(name: 'devops::security platform', color: '#E44D2A'),
      ),
    );

    expect(find.text('devops'), findsOneWidget);
    expect(find.text('security platform'), findsOneWidget);
    // Never the raw name with the separator showing.
    expect(find.text('devops::security platform'), findsNothing);
  });

  testWidgets('the scope carries the label colour, the value does not', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(const GitLabLabel(name: 'type::feature', color: '#428BCA')),
    );

    final scope = tester.widget<DecoratedBox>(
      find
          .ancestor(of: find.text('type'), matching: find.byType(DecoratedBox))
          .first,
    );
    expect(
      (scope.decoration as BoxDecoration).color,
      const Color(0xFF428BCA),
      reason: 'the scope segment is the label colour, as on gitlab.com',
    );
  });

  testWidgets('a single colon is not a scope', (tester) async {
    await tester.pumpWidget(
      _harness(
        const GitLabLabel(name: 'Category:Secrets Manager', color: '#428BCA'),
      ),
    );

    // gitlab.com renders this as one plain pill; splitting on ':' would break
    // every label with a colon in its name.
    expect(find.text('Category:Secrets Manager'), findsOneWidget);
    expect(find.text('Category'), findsNothing);
  });

  testWidgets('an ordinary label is unchanged', (tester) async {
    await tester.pumpWidget(
      _harness(const GitLabLabel(name: 'backend', color: '#D9534F')),
    );

    expect(find.text('backend'), findsOneWidget);
  });

  testWidgets(
    'a trailing or leading separator does not produce an empty side',
    (tester) async {
      for (final name in ['workflow::', '::orphan', 'a::b::c']) {
        await tester.pumpWidget(
          _harness(GitLabLabel(name: name, color: '#666')),
        );
        await tester.pump();
        expect(
          tester.takeException(),
          isNull,
          reason: '"$name" should render rather than throw',
        );
      }
    },
  );

  testWidgets('text stays readable on a dark and a light label', (
    tester,
  ) async {
    for (final entry in {
      '#111111': Colors.white,
      '#F5F5F5': Colors.black,
    }.entries) {
      await tester.pumpWidget(
        _harness(GitLabLabel(name: 'scope::value', color: entry.key)),
      );
      final text = tester.widget<Text>(find.text('scope'));
      expect(
        text.style!.color,
        entry.value,
        reason: 'a ${entry.key} label needs ${entry.value} text',
      );
    }
  });
}
