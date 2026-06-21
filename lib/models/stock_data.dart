class StockData {
  final String symbol;
  final List<String> dates;
  final List<double> close;
  final List<double> ma50;
  final List<double> ma100;
  final List<double> ma200;
  final List<StockRow> tableData;
  final Predictions predictions;

  StockData({
    required this.symbol,
    required this.dates,
    required this.close,
    required this.ma50,
    required this.ma100,
    required this.ma200,
    required this.tableData,
    required this.predictions,
  });

  factory StockData.fromJson(Map<String, dynamic> json) {
    return StockData(
      symbol: (json['symbol'] as String?) ?? '',
      dates: _parseStringList(json['dates']),
      close: _parseDoubleList(json['close']),
      ma50: _parseDoubleList(json['ma_50']),
      ma100: _parseDoubleList(json['ma_100']),
      ma200: _parseDoubleList(json['ma_200']),
      tableData: _parseTableData(json['table_data']),
      predictions: Predictions.fromJson(
        json['predictions'] is Map ? json['predictions'] as Map<String, dynamic> : {},
      ),
    );
  }

  // ── Safe list parsers ─────────────────────────────────────────────────────

  /// Safely converts any list-typed JSON field to `List<String>`.
  static List<String> _parseStringList(dynamic raw) {
    if (raw is! List) return [];
    return raw.map((e) => e?.toString() ?? '').toList();
  }

  /// Safely converts any list-typed JSON field to `List<double>`.
  /// Handles `int`, `double`, `String`, and `null` elements without throwing.
  static List<double> _parseDoubleList(dynamic raw) {
    if (raw is! List) return [];
    return raw.map<double>((e) {
      if (e == null) return 0.0;
      if (e is num) return e.toDouble();
      return double.tryParse(e.toString()) ?? 0.0;
    }).toList();
  }

  /// Safely converts the `table_data` JSON field to `List<StockRow>`.
  static List<StockRow> _parseTableData(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((e) => StockRow.fromJson(e))
        .toList();
  }
}

class StockRow {
  final String date;
  final double close;
  final double open;
  final double high;
  final double low;
  final int volume;

  StockRow({
    required this.date,
    required this.close,
    required this.open,
    required this.high,
    required this.low,
    required this.volume,
  });

  factory StockRow.fromJson(Map<String, dynamic> json) {
    return StockRow(
      date: (json['date'] as String?) ?? '',
      close: _safeDouble(json['close']),
      open: _safeDouble(json['open']),
      high: _safeDouble(json['high']),
      low: _safeDouble(json['low']),
      volume: _safeInt(json['volume']),
    );
  }

  static double _safeDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int _safeInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}

class Predictions {
  final List<String> dates;
  final List<double> actual;
  final List<double> predicted;

  Predictions({
    required this.dates,
    required this.actual,
    required this.predicted,
  });

  factory Predictions.fromJson(Map<String, dynamic> json) {
    return Predictions(
      dates: StockData._parseStringList(json['dates']),
      actual: StockData._parseDoubleList(json['actual']),
      predicted: StockData._parseDoubleList(json['predicted']),
    );
  }
}
