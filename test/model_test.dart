import 'package:flutter_test/flutter_test.dart';
import 'package:stock_price_prediction_frontend/models/stock_data.dart';

void main() {
  // ──────────────────────────────────────────────────────────────────
  // StockData.fromJson
  // ──────────────────────────────────────────────────────────────────
  group('StockData.fromJson', () {
    test('parses a well-formed response correctly', () {
      final json = {
        'symbol': 'AAPL',
        'dates': ['2024-01-01', '2024-01-02'],
        'close': [180.5, 182.0],
        'ma_50': [175.0, 176.0],
        'ma_100': [170.0, 171.0],
        'ma_200': [160.0, 161.0],
        'table_data': [
          {
            'date': '2024-01-02',
            'close': 182.0,
            'open': 181.0,
            'high': 183.5,
            'low': 180.0,
            'volume': 55000000,
          }
        ],
        'predictions': {
          'dates': ['2024-01-01'],
          'actual': [180.0],
          'predicted': [181.0],
        },
      };

      final data = StockData.fromJson(json);

      expect(data.symbol, 'AAPL');
      expect(data.dates, ['2024-01-01', '2024-01-02']);
      expect(data.close, [180.5, 182.0]);
      expect(data.ma50, [175.0, 176.0]);
      expect(data.ma100, [170.0, 171.0]);
      expect(data.ma200, [160.0, 161.0]);
      expect(data.tableData.length, 1);
      expect(data.tableData.first.date, '2024-01-02');
      expect(data.tableData.first.volume, 55000000);
      expect(data.predictions.actual, [180.0]);
      expect(data.predictions.predicted, [181.0]);
    });

    test('handles null top-level fields gracefully', () {
      final data = StockData.fromJson({});

      expect(data.symbol, '');
      expect(data.dates, isEmpty);
      expect(data.close, isEmpty);
      expect(data.ma50, isEmpty);
      expect(data.ma100, isEmpty);
      expect(data.ma200, isEmpty);
      expect(data.tableData, isEmpty);
      expect(data.predictions.dates, isEmpty);
      expect(data.predictions.actual, isEmpty);
      expect(data.predictions.predicted, isEmpty);
    });

    test('handles null elements inside numeric lists', () {
      final json = {
        'symbol': 'TEST',
        'close': [100.0, null, 102.0],
        'ma_50': [null, null],
      };

      final data = StockData.fromJson(json);

      expect(data.close, [100.0, 0.0, 102.0]);
      expect(data.ma50, [0.0, 0.0]);
    });

    test('handles integer elements in double lists', () {
      final json = {
        'symbol': 'TEST',
        'close': [100, 101, 102], // ints, not doubles
      };

      final data = StockData.fromJson(json);
      expect(data.close, [100.0, 101.0, 102.0]);
    });

    test('handles string-encoded numbers in numeric lists', () {
      final json = {
        'symbol': 'TEST',
        'close': ['150.5', '151.0'],
      };

      final data = StockData.fromJson(json);
      expect(data.close, [150.5, 151.0]);
    });

    test('handles non-list type for array fields without crashing', () {
      final json = {
        'symbol': 'TEST',
        'close': 'not-a-list', // wrong type
        'table_data': 'also-not-a-list',
      };

      final data = StockData.fromJson(json);
      expect(data.close, isEmpty);
      expect(data.tableData, isEmpty);
    });

    test('handles non-map type for predictions without crashing', () {
      final json = {
        'symbol': 'TEST',
        'predictions': 'bad-value',
      };

      final data = StockData.fromJson(json);
      expect(data.predictions.actual, isEmpty);
      expect(data.predictions.predicted, isEmpty);
    });
  });

  // ──────────────────────────────────────────────────────────────────
  // StockRow.fromJson
  // ──────────────────────────────────────────────────────────────────
  group('StockRow.fromJson', () {
    test('parses a well-formed row', () {
      final row = StockRow.fromJson({
        'date': '2024-01-01',
        'close': 180.5,
        'open': 179.0,
        'high': 181.0,
        'low': 178.5,
        'volume': 60000000,
      });

      expect(row.date, '2024-01-01');
      expect(row.close, 180.5);
      expect(row.open, 179.0);
      expect(row.high, 181.0);
      expect(row.low, 178.5);
      expect(row.volume, 60000000);
    });

    test('defaults missing fields to zero', () {
      final row = StockRow.fromJson({});

      expect(row.date, '');
      expect(row.close, 0.0);
      expect(row.open, 0.0);
      expect(row.high, 0.0);
      expect(row.low, 0.0);
      expect(row.volume, 0);
    });

    test('safely converts integer volume from num', () {
      final row = StockRow.fromJson({'volume': 1234567.89});
      expect(row.volume, 1234567);
    });
  });

  // ──────────────────────────────────────────────────────────────────
  // Predictions.fromJson
  // ──────────────────────────────────────────────────────────────────
  group('Predictions.fromJson', () {
    test('parses a well-formed predictions block', () {
      final p = Predictions.fromJson({
        'dates': ['2024-01-01', '2024-01-02'],
        'actual': [180.0, 182.0],
        'predicted': [181.0, 183.0],
      });

      expect(p.dates.length, 2);
      expect(p.actual, [180.0, 182.0]);
      expect(p.predicted, [181.0, 183.0]);
    });

    test('returns empty lists when predictions block is empty', () {
      final p = Predictions.fromJson({});

      expect(p.dates, isEmpty);
      expect(p.actual, isEmpty);
      expect(p.predicted, isEmpty);
    });
  });
}
