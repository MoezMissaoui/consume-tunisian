class ScanHistory {
  final String code;
  final String format;
  final String country;
  final DateTime scanDate;

  ScanHistory({
    required this.code,
    required this.format,
    required this.country,
    required this.scanDate,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'format': format,
    'country': country,
    'scanDate': scanDate.toIso8601String(),
  };

  factory ScanHistory.fromJson(Map<String, dynamic> json) => ScanHistory(
    code: json['code'],
    format: json['format'],
    country: json['country'],
    scanDate: DateTime.parse(json['scanDate']),
  );
}
