import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

Future<void> saveAndShareFile(String fileName, String content) async {
  // 1. Convert content to bytes
  final bytes = Uint8List.fromList(utf8.encode(content));

  // 2. Open the native "Save As" dialog
  // On mobile (Android/iOS), the 'bytes' parameter is mandatory and the plugin 
  // handles the writing process. On Desktop, it also handles the write if bytes are provided.
  await FilePicker.saveFile(
    dialogTitle: 'Save File',
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: ['csv'],
    bytes: bytes,
  );
}




