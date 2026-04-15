import 'package:flutter/services.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'db_platform_helper.dart';

class WebDbHelper extends DbPlatformHelper {
  @override
  Future<void> initialize() async {
    // No-op for web factory initialization if using direct global
  }


  @override
  DatabaseFactory get factory => databaseFactoryFfiWeb;

  @override
  Future<void> copyFromAssets(String dbPath, String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await databaseFactoryFfiWeb.writeDatabaseBytes(dbPath, bytes);
  }
}

DbPlatformHelper getHelper() => WebDbHelper();
