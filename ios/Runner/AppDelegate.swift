import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
  // TODO: Add your Google Maps API key
    GMSServices.provideAPIKey("AIzaSyB6AfQUuV4fZhJKPVCx3gejHXztQfu2y5I")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
