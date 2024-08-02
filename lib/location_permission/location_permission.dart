import 'package:permission_handler/permission_handler.dart';

Future<void> requestLocationPermission() async {
  var status = await Permission.location.request();
  if (status.isGranted) {
    print("Location permission granted.");
  } else if (status.isDenied) {
    requestLocationPermission();
  } else if (status.isPermanentlyDenied) {
    openAppSettings();
  }
}
