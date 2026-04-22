import 'dart:convert';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

Future<void> saveAndShareFile(String fileName, String content) async {
  if (Platform.isAndroid) {
    // 1. Request the "All Files Access" permission (Manage External Storage)
    // This is required on Android 11+ and Samsung devices to write to the Downloads folder
    var status = await Permission.manageExternalStorage.request();
    
    // Fallback for older Android versions
    if (status.isDenied) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      // 2. Direct path to the standard Android Downloads folder
      final downloadPath = '/storage/emulated/0/Download/$fileName';
      final file = File(downloadPath);
      
      // 3. Write the file
      await file.writeAsBytes(utf8.encode(content));
    } else if (status.isPermanentlyDenied) {
      // Open settings if the user has permanently denied permission
      await openAppSettings();
      throw Exception('Permission permanently denied. Please enable storage access in settings.');
    } else {
      throw Exception('Storage permission is required to save files to the Downloads folder.');
    }
  } else {
    // Non-Android fallback (e.g., if testing on other platforms)
    throw Exception('Direct download is only implemented for Android in this version.');
  }
}
