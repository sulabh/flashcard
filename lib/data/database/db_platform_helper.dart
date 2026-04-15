import 'package:sqflite_common/sqlite_api.dart';

import 'db_platform_stub.dart'
    if (dart.library.io) 'db_platform_native.dart'
    if (dart.library.html) 'db_platform_web.dart';

abstract class DbPlatformHelper {
  static DbPlatformHelper? _instance;
  static DbPlatformHelper get instance {
    _instance ??= getHelper();
    return _instance!;
  }

  Future<void> initialize();
  DatabaseFactory get factory;
  Future<void> copyFromAssets(String dbPath, String assetPath);
}
