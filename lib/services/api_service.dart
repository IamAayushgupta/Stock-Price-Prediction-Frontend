import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/stock_data.dart';

class ApiService {
  /// ─────────────────────────────────────────────────────────────────────────
  /// BACKEND URL CONFIGURATION
  ///
  /// The production URL is injected at build/run time via --dart-define.
  /// It is NEVER hardcoded in source control.
  ///
  /// Local dev:
  ///   flutter run -d chrome
  ///
  /// Production build (Vercel / GitHub Actions):
  ///   flutter build web --dart-define=BACKEND_URL=https://your-backend.onrender.com
  ///
  /// If BACKEND_URL is not supplied the app falls back to the default production URL,
  /// which points to the Render backend service.
  /// ─────────────────────────────────────────────────────────────────────────
  static const String _productionBackendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://stock-price-prediction-backend-76y5.onrender.com',
  );

  /// Local development backend (flutter run -d chrome hits this automatically)
  static const String _localBackendUrl = 'http://localhost:8000';

  /// Maximum time to wait for a response (Render free tier can be slow to wake).
  static const Duration _timeout = Duration(seconds: 45);

  static String getBaseUrl() {
    if (kIsWeb) {
      final currentUrl = Uri.base;
      final isLocalhost =
          currentUrl.host == 'localhost' || currentUrl.host == '127.0.0.1';
      return isLocalhost ? _localBackendUrl : _productionBackendUrl;
    } else {
      return _productionBackendUrl;
    }
  }

  static Future<bool> checkBackendHealth() async {
    try {
      // Use the first API (fetchStockData) to check backend health.
      // We query with a default symbol like 'AAPL' to verify the service is functional.
      await fetchStockData('AAPL');
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<StockData> fetchStockData(String symbol) async {
    final baseUrl = getBaseUrl();

    final uri = Uri.parse('$baseUrl/api/predict?symbol=$symbol');

    try {
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        late final Map<String, dynamic> data;
        try {
          data = json.decode(response.body) as Map<String, dynamic>;
        } on FormatException {
          throw Exception(
            'The server returned an unexpected response. Please try again.',
          );
        }

        if (data.containsKey('error')) {
          throw Exception(data['error']);
        }
        return StockData.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception(
          'Ticker "$symbol" not found. Please check the symbol and try again.',
        );
      } else if (response.statusCode == 422) {
        throw Exception(
          'Invalid ticker symbol. Please use a valid US stock ticker (e.g. AAPL, TSLA).',
        );
      } else if (response.statusCode >= 500) {
        throw Exception(
          'The prediction server encountered an error (${response.statusCode}). Please try again later.',
        );
      } else {
        throw Exception(
          'Unexpected server response (status ${response.statusCode}).',
        );
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. The server may be waking up — please try again in a moment.',
      );
    } on SocketException {
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    } on HandshakeException {
      throw Exception(
        'Secure connection failed. Please check your network settings.',
      );
    } on FormatException {
      throw Exception(
        'The server returned an unexpected response. Please try again.',
      );
    }
    // All other exceptions (including the ones we throw above) propagate up.
  }
}
