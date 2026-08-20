import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<LabFoxTextRoles> _roles(WidgetTester tester, ThemeData theme) async {
  late LabFoxTextRoles roles;
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      themeAnimationDuration: Duration.zero,
      home: Builder(
        builder: (context) {
          roles = LabFoxTextRoles.of(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return roles;
}

void main() {
  group('LabFoxTextRoles', () {
    testWidgets('the hierarchy steps down from headline to meta', (
      tester,
    ) async {
      final roles = await _roles(tester, LabFoxTheme.light);

      // Each level is strictly smaller than the one above it, so the page
      // reads as headline > section header > row title > meta.
      expect(
        roles.pageHeadline.fontSize!,
        greaterThan(roles.sectionHeader.fontSize!),
      );
      expect(
        roles.sectionHeader.fontSize!,
        greaterThan(roles.rowTitle.fontSize!),
      );
      expect(roles.rowTitle.fontSize!, greaterThan(roles.meta.fontSize!));
    });

    testWidgets('section headers are heavier than row titles', (tester) async {
      final roles = await _roles(tester, LabFoxTheme.light);
      expect(
        roles.sectionHeader.fontWeight!.index,
        greaterThan(roles.rowTitle.fontWeight!.index),
      );
    });

    testWidgets('meta is muted in both themes', (tester) async {
      for (final theme in [LabFoxTheme.light, LabFoxTheme.dark]) {
        final roles = await _roles(tester, theme);
        expect(roles.meta.color, theme.colorScheme.onSurfaceVariant);
      }
    });
  });

  group('size and radius tokens', () {
    test('icon sizes step up through the scale', () {
      expect(LabFoxIconSize.sm, lessThan(LabFoxIconSize.md));
      expect(LabFoxIconSize.md, lessThan(LabFoxIconSize.lg));
      expect(LabFoxIconSize.lg, lessThan(LabFoxIconSize.xl));
    });

    test('radii step up through the scale', () {
      expect(LabFoxRadius.xs, lessThan(LabFoxRadius.sm));
      expect(LabFoxRadius.sm, lessThan(LabFoxRadius.md));
      expect(LabFoxRadius.md, lessThan(LabFoxRadius.lg));
    });
  });

  group('LabFoxIcons', () {
    test('open and closed states use distinct glyphs', () {
      expect(LabFoxIcons.issueOpen, isNot(LabFoxIcons.issueClosed));
      expect(LabFoxIcons.mergeRequest, isNot(LabFoxIcons.merged));
    });
  });
}
