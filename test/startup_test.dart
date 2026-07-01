import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:stock_price_prediction_frontend/models/news_model.dart';
import 'package:stock_price_prediction_frontend/controllers/startup_controller.dart';

void main() {
  group('NewsModel parsing tests', () {
    test('parses a well-formed news article correctly', () {
      final json = {
        'title': 'Tesla Stock Surges on AI Enthusiasm',
        'description': 'Tesla shares jumped 5% today following announcements of new computing clusters.',
        'source': 'Reuters',
        'published_at': '2026-06-25T12:30:00.000000Z',
        'image_url': 'https://example.com/tesla.jpg',
        'url': 'https://reuters.com/tesla-stock-surges',
      };

      final news = NewsModel.fromJson(json);

      expect(news.title, 'Tesla Stock Surges on AI Enthusiasm');
      expect(news.description, 'Tesla shares jumped 5% today following announcements of new computing clusters.');
      expect(news.source, 'Reuters');
      expect(news.publishedAt.year, 2026);
      expect(news.publishedAt.month, 6);
      expect(news.publishedAt.day, 25);
      expect(news.imageUrl, 'https://example.com/tesla.jpg');
      expect(news.url, 'https://reuters.com/tesla-stock-surges');
    });

    test('handles missing optional fields gracefully', () {
      final json = {
        'title': 'Simple Headline',
        'url': 'https://example.com',
      };

      final news = NewsModel.fromJson(json);

      expect(news.title, 'Simple Headline');
      expect(news.description, '');
      expect(news.source, '');
      expect(news.imageUrl, isNull);
      expect(news.url, 'https://example.com');
    });

    test('serializes to json correctly', () {
      final news = NewsModel(
        title: 'Apple Launch',
        description: 'New Apple devices announced',
        source: 'Bloomberg',
        publishedAt: DateTime.parse('2026-06-25T10:00:00Z'),
        imageUrl: 'https://bloomberg.com/apple.jpg',
        url: 'https://bloomberg.com/apple-launch',
      );

      final json = news.toJson();

      expect(json['title'], 'Apple Launch');
      expect(json['description'], 'New Apple devices announced');
      expect(json['source'], 'Bloomberg');
      expect(json['published_at'], '2026-06-25T10:00:00.000Z');
      expect(json['image_url'], 'https://bloomberg.com/apple.jpg');
      expect(json['url'], 'https://bloomberg.com/apple-launch');
    });
  });

  group('StartupController tests', () {
    late StartupController controller;

    setUp(() {
      controller = Get.put(StartupController());
    });

    tearDown(() {
      Get.delete<StartupController>();
    });

    test('initializes with default values', () {
      expect(controller.newsList, isEmpty);
      expect(controller.isLoadingNews.value, isTrue);
      expect(controller.isBackendReady.value, isFalse);
      expect(controller.currentStatusMessage.value, '✓ Connecting securely');
      expect(controller.currentNewsIndex.value, 0);
      expect(controller.currentFactIndex.value, 0);
    });

    test('defines all standard status messages and finance facts', () {
      expect(StartupController.statusMessages.length, 4);
      expect(StartupController.financeFacts.length, greaterThanOrEqualTo(5));
      expect(StartupController.statusMessages, contains("✓ Waking cloud server"));
      expect(StartupController.financeFacts, contains("Investing regularly often beats trying to time the market."));
    });
  });
}
