// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as web;

Future<String?> pickDemoHtml() async {
  final input = web.FileUploadInputElement()
    ..accept = '.html,.htm'
    ..multiple = false;
  final done = Completer<String?>();
  input.onChange.listen((_) async {
    try {
      final files = input.files;
      if (files == null || files.isEmpty) {
        if (!done.isCompleted) done.complete(null);
        return;
      }
      if (files.single.size > 200000) {
        throw const FormatException('Arquivo excede 200 KB.');
      }
      final reader = web.FileReader();
      final loaded = reader.onLoad.first;
      reader.onError.first.then((_) {
        if (!done.isCompleted) {
          done.completeError(
            const FormatException('Não foi possível ler o arquivo.'),
          );
        }
      });
      reader.readAsText(files.single, 'UTF-8');
      await loaded;
      if (!done.isCompleted) done.complete(reader.result as String);
    } catch (e) {
      if (!done.isCompleted) done.completeError(e);
    }
  });
  input.addEventListener('cancel', (_) {
    if (!done.isCompleted) done.complete(null);
  });
  input.style.display = 'none';
  web.document.body!.append(input);
  input.click();
  try {
    return await done.future;
  } finally {
    input.remove();
  }
}

void downloadDemoHtml() {
  web.AnchorElement(href: 'exemplos/vendas-ficticias.html')
    ..download = 'vendas-ficticias.html'
    ..click();
}
