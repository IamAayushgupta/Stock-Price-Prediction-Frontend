import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_model.dart';

class MarketauxService {
  static const String _baseUrl = 'https://api.marketaux.com/v1/news/all';
  
  // Stored securely using --dart-define
  static const String _apiKey = String.fromEnvironment(
    'MARKETAUX_API_KEY',
    defaultValue: '',
  );

  /// Fetch latest market news.
  /// If it succeeds, caches the news and returns it.
  /// If it fails, reads from cache. If cache is empty, returns empty list.
  static Future<List<NewsModel>> fetchNews() async {
    if (_apiKey.isEmpty) {
      // No API key provided, fallback directly to cache
      return _loadFromCache();
    }

    // Free tier of Marketaux has strict limitations, filter by language = en and limit to 5
    final uri = Uri.parse('$_baseUrl?api_token=$_apiKey&limit=5&language=en');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic>? articlesJson = data['data'] as List<dynamic>?;
        if (articlesJson != null) {
          final newsList = articlesJson
              .map((item) => NewsModel.fromJson(item as Map<String, dynamic>))
              .toList();
          if (newsList.isNotEmpty) {
            await _saveToCache(newsList);
            return newsList;
          }
        }
      }
      return _loadFromCache();
    } catch (_) {
      return _loadFromCache();
    }
  }

  static Future<List<NewsModel>> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? newsJson = prefs.getString('cached_market_news');
      if (newsJson != null) {
        final List<dynamic> decoded = jsonDecode(newsJson);
        return decoded.map((item) => NewsModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Ignore cache load errors
    }
    return [];
  }

  static Future<void> _saveToCache(List<NewsModel> newsList) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String newsJson = jsonEncode(newsList.map((n) => n.toJson()).toList());
      await prefs.setString('cached_market_news', newsJson);
    } catch (_) {
      // Ignore cache save errors
    }
  }
}
