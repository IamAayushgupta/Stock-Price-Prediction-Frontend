import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';
import '../models/news_model.dart';
import '../services/api_service.dart';
import '../services/marketaux_service.dart';
import '../screens/dashboard_screen.dart';

class StartupController extends GetxController {
  final RxList<NewsModel> newsList = <NewsModel>[].obs;
  final RxBool isLoadingNews = true.obs;
  final RxBool isBackendReady = false.obs;
  final RxString currentStatusMessage = "✓ Connecting securely".obs;
  final RxInt currentNewsIndex = 0.obs;
  final RxInt currentFactIndex = 0.obs;

  Timer? _statusTimer;
  Timer? _newsCarouselTimer;
  Timer? _factCarouselTimer;
  Timer? _backendPingTimer;

  static const List<String> statusMessages = [
    "✓ Connecting securely",
    "✓ Waking cloud server",
    "✓ Fetching today's market news",
    "✓ Preparing AI engine",
  ];

  static const List<String> financeFacts = [
    "Investing regularly often beats trying to time the market.",
    "Diversification helps reduce investment risk.",
    "Warren Buffett bought his first stock at age 11.",
    "The oldest stock exchange in the world was established in Amsterdam in 1602.",
    "Bull markets strike upwards with their horns, while bear markets swipe downwards.",
    "Over the long term, stocks have historically outperformed cash and bonds.",
    "Compound interest is the eighth wonder of the world.",
  ];

  int _statusIndex = 0;

  @override
  void onInit() {
    super.onInit();
    _startStatusRotation();
    _startFactRotation();
    _fetchNews();
    _startBackendPing();
  }

  @override
  void onClose() {
    _cancelAllTimers();
    super.onClose();
  }

  void _cancelAllTimers() {
    _statusTimer?.cancel();
    _newsCarouselTimer?.cancel();
    _factCarouselTimer?.cancel();
    _backendPingTimer?.cancel();
    log("StartupController: All timers cancelled.");
  }

  // 1. Rotate Status Messages
  void _startStatusRotation() {
    _statusTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      _statusIndex = (_statusIndex + 1) % statusMessages.length;
      currentStatusMessage.value = statusMessages[_statusIndex];
    });
  }

  // 2. Rotate Finance Facts (if news is empty)
  void _startFactRotation() {
    _factCarouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (newsList.isEmpty) {
        currentFactIndex.value =
            (currentFactIndex.value + 1) % financeFacts.length;
      }
    });
  }

  // 3. Auto-sliding news carousel
  void _startNewsCarousel() {
    _newsCarouselTimer?.cancel();
    if (newsList.isNotEmpty) {
      _newsCarouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        currentNewsIndex.value = (currentNewsIndex.value + 1) % newsList.length;
      });
    }
  }

  // 4. Fetch Market News
  Future<void> _fetchNews() async {
    isLoadingNews.value = true;
    try {
      final fetchedNews = await MarketauxService.fetchNews();
      newsList.assignAll(fetchedNews);
      if (newsList.isNotEmpty) {
        _startNewsCarousel();
      }
    } catch (e) {
      log("StartupController: Error fetching news: $e");
    } finally {
      isLoadingNews.value = false;
    }
  }

  // 5. Backend Warm-up / Ping loop
  void _startBackendPing() {
    // Immediate ping on start
    _pingBackend();

    _backendPingTimer = Timer.periodic(const Duration(seconds: 30), (
      timer,
    ) async {
      if (!isBackendReady.value) {
        await _pingBackend();
      }
    });
  }

  Future<void> _pingBackend() async {
    log("StartupController: Pinging backend...");
    final ready = await ApiService.checkBackendHealth();
    if (ready) {
      log("StartupController: Backend is ready!");
      isBackendReady.value = true;
      _backendPingTimer?.cancel();

      // Delay navigation slightly so the user experiences the premium transition and status messages
      Future.delayed(const Duration(milliseconds: 800), () {
        _navigateToDashboard();
      });
    } else {
      log("StartupController: Backend not ready yet.");
    }
  }

  void _navigateToDashboard() {
    _cancelAllTimers();
    Get.off(() => const DashboardScreen());
  }
}
