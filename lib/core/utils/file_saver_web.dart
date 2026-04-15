import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> saveAndShareFile(String fileName, String content) async {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(blob);
  
  // Create a hidden anchor element and trigger the download
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();
    
  // Cleanup
  html.Url.revokeObjectUrl(url);
}
