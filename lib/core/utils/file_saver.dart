import 'file_saver_native.dart'
    if (dart.library.html) 'file_saver_web.dart'
    if (dart.library.js_interop) 'file_saver_web.dart';

class FileSaver {
  /// Saves the given [content] as a file with [fileName] and shares/downloads it
  /// depending on the platform.
  static Future<void> saveAndShare({
    required String fileName,
    required String content,
  }) async {
    return saveAndShareFile(fileName, content);
  }
}
