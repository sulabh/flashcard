import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'db_platform_helper.dart';

class NativeDbHelper extends DbPlatformHelper {
  @override
  Future<void> initialize() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  @override
  DatabaseFactory get factory => databaseFactory;

  @override
  Future<void> copyFromAssets(String dbPath, String assetPath) async {
    // Ensure the directory exists
    try {
      await Directory(dirname(dbPath)).create(recursive: true);
    } catch (_) {}

    // Copy from assets
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(dbPath).writeAsBytes(bytes, flush: true);
  }
}

DbPlatformHelper getHelper() => NativeDbHelper();
