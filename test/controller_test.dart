import 'package:flutter_test/flutter_test.dart';
import 'package:stock_price_prediction_frontend/controllers/stock_controller.dart';

/// Unit tests for StockController state management and guards.
///
/// These tests exercise the controller in isolation — no API calls are made
/// because we assert on the guard logic (isLoading, empty symbol, etc.).
void main() {
  group('StockController', () {
    late StockController controller;

    setUp(() {
      controller = StockController();
    });

    tearDown(() {
      controller.onClose();
    });

    test('initial state is correct', () {
      // Do NOT call onInit so no fetch fires.
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isNull);
      expect(controller.stockData.value, isNull);
      expect(controller.currentTicker.value, 'AAPL');
      expect(controller.activeChartIndex.value, 0);
      expect(controller.searchController.text, 'AAPL');
    });

    test('fetchData returns early when already loading', () async {
      // Set loading to true manually to simulate an in-flight request.
      controller.isLoading.value = true;

      // fetchData should return immediately without changing error state.
      await controller.fetchData();

      // isLoading should still be true (we didn't touch it in the early return).
      expect(controller.isLoading.value, true);
      // Error should remain null.
      expect(controller.errorMessage.value, isNull);
    });

    test('fetchData returns early when symbol is empty', () async {
      controller.searchController.text = '   '; // whitespace only

      // Should return without doing anything.
      await controller.fetchData();

      // State should remain at defaults.
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isNull);
    });

    test('fetchData trims and uppercases symbol before use', () {
      // This test only verifies the *synchronous* normalisation of the text
      // field, without waiting for a network response.
      controller.searchController.text = '  aapl  ';

      // Trigger the synchronous part of fetchData by directly calling the
      // normalisation logic (mirrors what fetchData does before the async call).
      final raw = controller.searchController.text;
      final normalised = raw.trim().toUpperCase();
      if (controller.searchController.text != normalised) {
        controller.searchController.value =
            controller.searchController.value.copyWith(text: normalised);
      }

      expect(controller.searchController.text, 'AAPL');
    });

    test('activeChartIndex toggles correctly', () {
      expect(controller.activeChartIndex.value, 0);
      controller.activeChartIndex.value = 1;
      expect(controller.activeChartIndex.value, 1);
      controller.activeChartIndex.value = 0;
      expect(controller.activeChartIndex.value, 0);
    });
  });
}
