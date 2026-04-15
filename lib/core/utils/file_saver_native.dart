import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> saveAndShareFile(String fileName, String content) async {
  final directory = await getTemporaryDirectory();
  final path = "${directory.path}/$fileName";
  final file = File(path);
  await file.writeAsString(content);

  await Share.shareXFiles([XFile(path)], subject: 'RubyStudy Export');
}
