import Flutter
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate {
  /// The unique name the background to-do check is scheduled under in Dart,
  /// and the BGTaskScheduler identifier permitted in Info.plist. All three
  /// have to be the same string or iOS silently runs nothing.
  private static let backgroundTaskIdentifier = "labfox.todo_check.periodic"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // BGTaskScheduler only accepts a launch handler registered before this
    // method returns. Registering it here is what makes the setting mean
    // anything on iOS: the Dart side can schedule the task either way, but
    // without a handler the system has nothing to run and never says so.
    //
    // The interval is a floor, not a promise — iOS decides when a background
    // refresh actually runs.
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: AppDelegate.backgroundTaskIdentifier,
      earliestBeginInSeconds: 15 * 60
    )
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
