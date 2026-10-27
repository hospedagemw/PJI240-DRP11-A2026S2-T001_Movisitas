import '../domain/order.dart';

class ParsedOrderRow {
  const ParsedOrderRow({
    required this.sourceTitle,
    required this.issuedAt,
    required this.internalCode,
    required this.clientName,
    required this.baseValue,
    required this.importKey,
  });

  final String sourceTitle;
  final DateTime issuedAt;
  final String internalCode;
  final String clientName;
  final double baseValue;
  final String importKey;
}

class OrderHtmlParser {
  const OrderHtmlParser();

  List<ParsedOrderRow> parse(String html) {
    final rows = _parseTableRows(html);
    if (rows.isNotEmpty) return rows;
    return _parseCrystalReportRows(html);
  }

  List<ParsedOrderRow> _parseTableRows(String html) {
    final rows = <ParsedOrderRow>[];
    final tableRows = RegExp(
      r'<tr\b[^>]*>([\s\S]*?)</tr>',
      caseSensitive: false,
    ).allMatches(html);
    for (final tableRow in tableRows) {
      final cells =
          RegExp(r'<t[dh]\b[^>]*>([\s\S]*?)</t[dh]>', caseSensitive: false)
              .allMatches(tableRow.group(1) ?? '')
              .map((match) => _cleanCell(match.group(1) ?? ''))
              .toList();
      if (cells.length < 6) continue;
      final issuedAt = _parseDate(cells[1]);
      final internalCode = cells[3].replaceAll(RegExp(r'\D'), '');
      final baseValue = _parseBrazilianNumber(cells[5]);
      if (issuedAt == null || internalCode.isEmpty || baseValue == null) {
        continue;
      }
      final sourceTitle = cells.first.trim();
      final clientName = cells[4].trim();
      final rawKey = [
        sourceTitle,
        _isoDate(issuedAt),
        internalCode,
        baseValue.toStringAsFixed(2),
      ].join('|');
      rows.add(
        ParsedOrderRow(
          sourceTitle: sourceTitle,
          issuedAt: issuedAt,
          internalCode: internalCode,
          clientName: clientName,
          baseValue: baseValue,
          importKey: _stableKey(rawKey),
        ),
      );
    }
    return rows;
  }

  List<ParsedOrderRow> _parseCrystalReportRows(String html) {
    final positioned = <int, Map<int, String>>{};
    final divs = RegExp(
      r'<div\b([^>]*)>([\s\S]*?)</div>',
      caseSensitive: false,
    ).allMatches(html.replaceAll('\u0000', ''));
    for (final div in divs) {
      final attributes = div.group(1) ?? '';
      if (!attributes.contains('title=')) continue;
      final topMatch = RegExp(
        r'top:\s*(\d+)px',
        caseSensitive: false,
      ).firstMatch(attributes);
      final leftMatch = RegExp(
        r'left:\s*(\d+)px',
        caseSensitive: false,
      ).firstMatch(attributes);
      if (topMatch == null || leftMatch == null) continue;
      final top = int.parse(topMatch.group(1)!);
      final left = int.parse(leftMatch.group(1)!);
      final text = _cleanCell(div.group(2) ?? '');
      if (text.isNotEmpty) positioned.putIfAbsent(top, () => {})[left] = text;
    }

    final rows = <ParsedOrderRow>[];
    for (final fields in positioned.values) {
      final sourceTitle = fields[8];
      final issuedAt = _parseDate(fields[104] ?? '');
      final internalCode = (fields[238] ?? '').replaceAll(RegExp(r'\D'), '');
      final clientName = fields[277];
      final baseValue = _parseBrazilianNumber(fields[558] ?? '');
      if (sourceTitle == null ||
          issuedAt == null ||
          internalCode.isEmpty ||
          clientName == null ||
          baseValue == null) {
        continue;
      }
      final rawKey = [
        sourceTitle,
        _isoDate(issuedAt),
        internalCode,
        baseValue.toStringAsFixed(2),
      ].join('|');
      rows.add(
        ParsedOrderRow(
          sourceTitle: sourceTitle,
          issuedAt: issuedAt,
          internalCode: internalCode,
          clientName: clientName,
          baseValue: baseValue,
          importKey: _stableKey(rawKey),
        ),
      );
    }
    rows.sort((left, right) => left.issuedAt.compareTo(right.issuedAt));
    return rows;
  }

  String _cleanCell(String value) => _decodeEntities(
    value
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim(),
  );

  String _decodeEntities(String value) => value
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&#160;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>');

  DateTime? _parseDate(String value) {
    final match = RegExp(r'\b(\d{2})/(\d{2})/(\d{4})\b').firstMatch(value);
    if (match == null) return null;
    return DateTime(
      int.parse(match.group(3)!),
      int.parse(match.group(2)!),
      int.parse(match.group(1)!),
    );
  }

  double? _parseBrazilianNumber(String value) {
    final normalized = value
        .replaceAll(RegExp(r'[^\d,.-]'), '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  String _isoDate(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  String _stableKey(String value) {
    var hash = 0x811c9dc5;
    for (final byte in value.codeUnits) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}

SalesOrder parsedOrderToDomain({
  required ParsedOrderRow row,
  required String clientId,
  required String clientName,
  required String sourceFile,
}) => SalesOrder(
  id: 'o${DateTime.now().microsecondsSinceEpoch}-${row.importKey}',
  clientId: clientId,
  internalCode: row.internalCode,
  clientName: clientName,
  issuedAt: row.issuedAt,
  baseValue: row.baseValue,
  sourceTitle: row.sourceTitle,
  importKey: row.importKey,
  sourceFile: sourceFile,
);
