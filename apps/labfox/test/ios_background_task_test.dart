import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/core/notifications/background_notifications.dart';

/// Guards the iOS half of the background check.
///
/// On iOS the work is run by BGTaskScheduler, which only knows a task that was
/// both permitted in `Info.plist` and registered with a launch handler before
/// `didFinishLaunchingWithOptions` returns. Miss either and the setting is a
/// switch that schedules nothing — Android would keep working, so the gap is
/// invisible from the Dart side.
///
/// The identifier iOS uses is the task's *unique* name, not its task name, so
/// all three places have to agree on exactly that string.
void main() {
  final plist = File('ios/Runner/Info.plist');
  final appDelegate = File('ios/Runner/AppDelegate.swift');

  test('Info.plist permits exactly the identifier Dart schedules', () {
    final contents = plist.readAsStringSync();

    expect(
      contents,
      contains('<string>$backgroundTaskIdentifier</string>'),
      reason: 'BGTaskScheduler refuses an identifier that is not permitted.',
    );
    // The old plugin's built-in fetch identifier is not what this app
    // schedules; leaving it in claims a capability the app does not use.
    expect(contents, isNot(contains('be.tramckrijte.workmanager')));
  });

  test('the AppDelegate registers the launch handler', () {
    final contents = appDelegate.readAsStringSync();

    expect(
      contents,
      contains('WorkmanagerPlugin.registerPeriodicTask'),
      reason: 'Without a launch handler iOS never runs the scheduled task.',
    );
    expect(contents, contains('"$backgroundTaskIdentifier"'));
    expect(
      contents,
      contains('import workmanager_apple'),
      reason: 'The registration API lives in the plugin module.',
    );
  });
}
