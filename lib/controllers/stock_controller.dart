import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/stock_data.dart';
import '../services/api_service.dart';

class StockController extends GetxController {
  final TextEditingController searchController = TextEditingController(
    text: 'AAPL',
  );

  final RxString currentTicker = 'AAPL'.obs;
  final Rxn<StockData> stockData = Rxn<StockData>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxInt activeChartIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchData() async {
    // ── Concurrent fetch guard ──────────────────────────────────────────────
    // Prevents a race condition when the user taps search multiple times while
    // a request is already in-flight.
    if (isLoading.value) return;

    // ── Input sanitisation ─────────────────────────────────────────────────
    final String symbol = searchController.text.trim().toUpperCase();
    if (symbol.isEmpty) return;

    // Normalise the text field to uppercase for consistency.
    if (searchController.text != symbol) {
      searchController.value = searchController.value.copyWith(text: symbol);
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      log('Fetching data for $symbol');
      final data = await ApiService.fetchStockData(symbol);
      stockData.value = data;
      currentTicker.value = symbol;
      log('Data fetched successfully for $symbol');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '').trim();
      log('Error fetching data for $symbol: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
