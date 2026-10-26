// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as web;

void downloadReport(String html, String filename) {
  final blob = web.Blob([html], 'text/html;charset=utf-8');
  final url = web.Url.createObjectUrlFromBlob(blob);
  final link = web.AnchorElement(href: url)..download = filename;
  web.document.body?.append(link);
  link.click();
  link.remove();
  Timer(const Duration(seconds: 30), () => web.Url.revokeObjectUrl(url));
}
