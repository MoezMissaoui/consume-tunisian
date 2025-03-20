import 'package:permission_handler/permission_handler.dart';

Future<bool> requestCameraPermission() async {
  PermissionStatus status = await Permission.camera.request();
  return status.isGranted;
}
