class SalesOrder {
  const SalesOrder({
    required this.id,
    required this.clientId,
    required this.internalCode,
    required this.clientName,
    required this.issuedAt,
    required this.baseValue,
    required this.sourceTitle,
    required this.importKey,
    this.sourceFile,
  });

  final String id;
  final String clientId;
  final String internalCode;
  final String clientName;
  final DateTime issuedAt;
  final double baseValue;
  final String sourceTitle;
  final String importKey;
  final String? sourceFile;
}

class OrderImportResult {
  const OrderImportResult({
    required this.imported,
    required this.duplicates,
    required this.unmatched,
    required this.invalid,
  });

  final int imported;
  final int duplicates;
  final List<String> unmatched;
  final int invalid;
}
