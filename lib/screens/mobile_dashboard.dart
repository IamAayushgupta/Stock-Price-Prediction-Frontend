import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/stock_controller.dart';
import '../models/stock_data.dart';
import '../models/stock_insight.dart';
import '../theme/app_theme.dart';
import '../widgets/ma_chart.dart';
import '../widgets/prediction_chart.dart';

/// Dedicated mobile layout for screen widths below 800px.
/// Reuses all existing charts, controllers, and business logic.
/// Uses raw pixel values (no ScreenUtil suffixes) to avoid scaling
/// issues with the 1440×900 ScreenUtil design size on narrow screens.
class MobileDashboard extends StatelessWidget {
  final StockController controller;

  const MobileDashboard({super.key, required this.controller});

  // ─────────────────────────────────────────────
  //  Insight Generator (mirrors desktop logic)
  // ─────────────────────────────────────────────
  List<StockInsight> _generateInsights() {
    final data = controller.stockData.value;
    if (data == null) return [];

    final List<StockInsight> insights = [];
    final double latestClose = data.close.isNotEmpty ? data.close.last : 0.0;

    // 1. Momentum Alert (Price vs. 50-Day MA)
    if (data.ma50.isNotEmpty) {
      final double ma50Last = data.ma50.last;
      if (ma50Last > 0) {
        final double pctDiff = ((latestClose - ma50Last) / ma50Last) * 100;
        if (latestClose >= ma50Last) {
          insights.add(
            StockInsight(
              title: 'Bullish Momentum',
              description:
                  '${controller.currentTicker.value} is trading ${pctDiff.toStringAsFixed(1)}% above its 50-day moving average (\$${ma50Last.toStringAsFixed(2)}), indicating strong short-term upward momentum.',
              icon: Icons.trending_up,
              color: AppTheme.accentColor,
            ),
          );
        } else {
          insights.add(
            StockInsight(
              title: 'Bearish Momentum',
              description:
                  '${controller.currentTicker.value} is trading ${pctDiff.abs().toStringAsFixed(1)}% below its 50-day moving average (\$${ma50Last.toStringAsFixed(2)}), suggesting a short-term downward phase.',
              icon: Icons.trending_down,
              color: AppTheme.warningColor,
            ),
          );
        }
      }
    }

    // 2. Moving Average Crossover (Golden/Death Cross)
    if (data.ma50.isNotEmpty && data.ma200.isNotEmpty) {
      final double ma50Last = data.ma50.last;
      final double ma200Last = data.ma200.last;
      if (ma50Last > 0 && ma200Last > 0) {
        if (ma50Last >= ma200Last) {
          insights.add(
            StockInsight(
              title: 'Golden Cross Alert',
              description:
                  'The 50-day MA (\$${ma50Last.toStringAsFixed(2)}) is above the 200-day MA (\$${ma200Last.toStringAsFixed(2)}), indicating a long-term bullish trend.',
              icon: Icons.swap_calls,
              color: AppTheme.accentColor,
            ),
          );
        } else {
          insights.add(
            StockInsight(
              title: 'Death Cross Alert',
              description:
                  'The 50-day MA (\$${ma50Last.toStringAsFixed(2)}) is below the 200-day MA (\$${ma200Last.toStringAsFixed(2)}), indicating a potential long-term bearish outlook.',
              icon: Icons.swap_calls,
              color: AppTheme.warningColor,
            ),
          );
        }
      }
    }

    // 3. LSTM Model Prediction Trend
    if (data.predictions.predicted.isNotEmpty) {
      final preds = data.predictions.predicted;
      if (preds.length >= 5) {
        final double lastPred = preds.last;
        final double prevPred = preds[preds.length - 5];
        // Guard: avoid division-by-zero if prevPred is 0.
        if (prevPred != 0) {
          final double diff = lastPred - prevPred;
          final double pctDiff = (diff / prevPred) * 100;
          if (diff > 0) {
            insights.add(
              StockInsight(
                title: 'LSTM Forecast',
                description:
                    'The LSTM model predicts a bullish trajectory, forecasting a +${pctDiff.toStringAsFixed(1)}% price appreciation over the final test periods.',
                icon: Icons.auto_graph,
                color: AppTheme.accentColor,
              ),
            );
          } else {
            insights.add(
              StockInsight(
                title: 'LSTM Forecast',
                description:
                    'The LSTM model predicts consolidation or downward pressure, forecasting a ${pctDiff.toStringAsFixed(1)}% price decline over the final test periods.',
                icon: Icons.auto_graph,
                color: AppTheme.warningColor,
              ),
            );
          }
        }
      }
    }

    // 4. Volatility / Price Range
    if (data.close.isNotEmpty) {
      final int periods = data.close.length > 30 ? 30 : data.close.length;
      final lastPrices = data.close.sublist(data.close.length - periods);
      double maxPrice = lastPrices.reduce((a, b) => a > b ? a : b);
      double minPrice = lastPrices.reduce((a, b) => a < b ? a : b);
      final double volatilityPct = ((maxPrice - minPrice) / minPrice) * 100;
      insights.add(
        StockInsight(
          title: 'Volatility & Range',
          description:
              'Over the last $periods trading periods, price fluctuated between \$${minPrice.toStringAsFixed(2)} and \$${maxPrice.toStringAsFixed(2)} (a ${volatilityPct.toStringAsFixed(1)}% spread).',
          icon: Icons.radar,
          color: AppTheme.ma100Color,
        ),
      );
    }

    insights.add(
      StockInsight(
        title: 'Inference Source',
        description:
            'Predictions are run dynamically via a client-side ONNX LSTM network utilizing real-time Yahoo Finance data.',
        icon: Icons.info_outline,
        color: AppTheme.textSecondaryDark,
      ),
    );

    return insights;
  }

  // ─────────────────────────────────────────────
  //  Root Build
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.isLoading.value) {
              return _buildLoading(context);
            } else if (controller.errorMessage.value != null) {
              return _buildError(context);
            } else if (controller.stockData.value != null) {
              return _buildContent(context);
            } else {
              return Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Center(
                  child: Text(
                    'Enter a stock symbol to get started',
                    style: TextStyle(
                      color: AppTheme.textSecondaryDark,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Header
  // ─────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/logo.png',
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stock Prediction',
                  style: TextStyle(
                    color: AppTheme.textPrimaryDark,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const Text(
                  'Deep Learning LSTM Forecasting Dashboard',
                  style: TextStyle(
                    color: AppTheme.textSecondaryDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Full-width search bar
        _buildSearchBar(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCardBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: TextField(
        controller: controller.searchController,
        onSubmitted: (_) => controller.fetchData(),
        textCapitalization: TextCapitalization.characters,
        style: const TextStyle(
          color: AppTheme.textPrimaryDark,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Enter Ticker (e.g. GOOG, TSLA)',
          hintStyle: const TextStyle(
            color: AppTheme.textSecondaryDark,
            fontWeight: FontWeight.normal,
            letterSpacing: 0,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 18,
            color: AppTheme.textSecondaryDark,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(5),
            child: SizedBox(
              width: 36,
              height: 36,
              child: IconButton(
                onPressed: controller.fetchData,
                icon: const Icon(Icons.arrow_forward, size: 15),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          filled: false,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppTheme.primaryColor,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Loading / Error States
  // ─────────────────────────────────────────────
  Widget _buildLoading(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: 3,
            ),
            const SizedBox(height: 18),
            const Text(
              'Fetching stock data & running LSTM inference…',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppTheme.warningColor,
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            'An Error Occurred',
            style: TextStyle(
              color: AppTheme.warningColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.errorMessage.value ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: controller.fetchData,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Main Content (all sections)
  // ─────────────────────────────────────────────
  Widget _buildContent(BuildContext context) {
    final data = controller.stockData.value!;
    final double latestClose = data.close.isNotEmpty ? data.close.last : 0.0;

    double change = 0.0;
    double changePercent = 0.0;
    if (data.close.length >= 2) {
      final double prevClose = data.close[data.close.length - 2];
      change = latestClose - prevClose;
      changePercent = (change / prevClose) * 100;
    }

    final double ma50Val = data.ma50.isNotEmpty ? data.ma50.last : 0.0;
    final double ma100Val = data.ma100.isNotEmpty ? data.ma100.last : 0.0;
    final double ma200Val = data.ma200.isNotEmpty ? data.ma200.last : 0.0;

    String varianceLabel(double maValue) {
      if (maValue <= 0 || latestClose <= 0) return 'N/A';
      final double v = ((maValue - latestClose) / latestClose) * 100;
      final String sign = v >= 0 ? '+' : '';
      return '($sign${v.toStringAsFixed(1)}% from current)';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── KPI 2×2 Grid ──────────────────────────
        LayoutBuilder(
          builder: (ctx, box) {
            final cardW = (box.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MobileKpiCard(
                  title: 'Latest Price',
                  value: '\$${latestClose.toStringAsFixed(2)}',
                  subtitle:
                      '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)} (${changePercent.toStringAsFixed(2)}%)',
                  color: change >= 0
                      ? AppTheme.accentColor
                      : AppTheme.warningColor,
                  icon: Icons.currency_exchange,
                  width: cardW,
                ),
                _MobileKpiCard(
                  title: '50-Day MA',
                  value: ma50Val > 0
                      ? '\$${ma50Val.toStringAsFixed(2)}'
                      : 'N/A',
                  subtitle: varianceLabel(ma50Val),
                  color: AppTheme.ma50Color,
                  icon: Icons.timeline,
                  width: cardW,
                  mutedSubtitle: true,
                ),
                _MobileKpiCard(
                  title: '100-Day MA',
                  value: ma100Val > 0
                      ? '\$${ma100Val.toStringAsFixed(2)}'
                      : 'N/A',
                  subtitle: varianceLabel(ma100Val),
                  color: AppTheme.ma100Color,
                  icon: Icons.analytics_outlined,
                  width: cardW,
                  mutedSubtitle: true,
                ),
                _MobileKpiCard(
                  title: '200-Day MA',
                  value: ma200Val > 0
                      ? '\$${ma200Val.toStringAsFixed(2)}'
                      : 'N/A',
                  subtitle: varianceLabel(ma200Val),
                  color: AppTheme.ma200Color,
                  icon: Icons.show_chart,
                  width: cardW,
                  mutedSubtitle: true,
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 16),

        // ── Chart ──────────────────────────────────
        _buildChartSection(data),

        const SizedBox(height: 16),

        // ── Model Insights ─────────────────────────
        _buildInsightsSection(),

        const SizedBox(height: 16),

        // ── Stock Data Table ───────────────────────
        _buildTableSection(data),

        const SizedBox(height: 24),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  Chart Section
  // ─────────────────────────────────────────────
  Widget _buildChartSection(StockData data) {
    return Container(
      height: 330,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: AppTheme.darkCardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + toggle row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Text(
                  controller.activeChartIndex.value == 0
                      ? 'Moving Averages'
                      : 'LSTM Prediction vs Actual',
                  style: const TextStyle(
                    color: AppTheme.textPrimaryDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: [
                  _buildChartTab('MAs', 0),
                  const SizedBox(width: 6),
                  _buildChartTab('LSTM', 1),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Chart body
          Expanded(
            child: Obx(
              () => controller.activeChartIndex.value == 0
                  ? MaChart(stockData: data)
                  : PredictionChart(stockData: data),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTab(String label, int index) {
    return Obx(() {
      final isActive = controller.activeChartIndex.value == index;
      return GestureDetector(
        onTap: () => controller.activeChartIndex.value = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primaryColor
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.55),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    });
  }

  // ─────────────────────────────────────────────
  //  Model Insights Section
  // ─────────────────────────────────────────────
  Widget _buildInsightsSection() {
    final insights = _generateInsights();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(Icons.analytics, color: AppTheme.secondaryColor, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Model Insights',
                style: TextStyle(
                  color: AppTheme.textPrimaryDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Insight cards
          ...List.generate(insights.length, (i) {
            final insight = insights[i];
            return Padding(
              padding: EdgeInsets.only(
                bottom: i == insights.length - 1 ? 0 : 10,
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: insight.color.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: insight.color.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon bubble
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: insight.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(insight.icon, color: insight.color, size: 14),
                    ),
                    const SizedBox(width: 10),
                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insight.title,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: insight.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            insight.description,
                            style: const TextStyle(
                              fontSize: 11.5,
                              height: 1.45,
                              color: AppTheme.textPrimaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Stock Data Table Section
  // ─────────────────────────────────────────────
  Widget _buildTableSection(StockData data) {
    return _MobileStockTable(
      tableData: data.tableData,
      ticker: controller.currentTicker.value,
    );
  }
}

// ═══════════════════════════════════════════════
//  _MobileKpiCard — raw-pixel KPI card for mobile
// ═══════════════════════════════════════════════
class _MobileKpiCard extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;
  final double width;
  final bool mutedSubtitle;

  const _MobileKpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.width,
    this.mutedSubtitle = false,
  });

  @override
  State<_MobileKpiCard> createState() => _MobileKpiCardState();
}

class _MobileKpiCardState extends State<_MobileKpiCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width,
        padding: const EdgeInsets.all(14),
        transform: Matrix4.diagonal3Values(
          _pressed ? 0.97 : 1.0,
          _pressed ? 0.97 : 1.0,
          1.0,
        ),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.darkCardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _pressed
                ? widget.color.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.08),
            width: _pressed ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _pressed
                  ? widget.color.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.2),
              blurRadius: _pressed ? 18 : 10,
              offset: _pressed ? const Offset(0, 6) : const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + icon row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textSecondaryDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Value
            Text(
              widget.value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: AppTheme.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 4),
            // Subtitle
            Text(
              widget.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: widget.mutedSubtitle
                    ? AppTheme.textSecondaryDark.withValues(alpha: 0.6)
                    : widget.color,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  _MobileStockTable — paginated table for mobile
// ═══════════════════════════════════════════════
class _MobileStockTable extends StatefulWidget {
  final List<StockRow> tableData;
  final String ticker;

  const _MobileStockTable({required this.tableData, required this.ticker});

  @override
  State<_MobileStockTable> createState() => _MobileStockTableState();
}

class _MobileStockTableState extends State<_MobileStockTable> {
  int _currentPage = 0;
  static const int _rowsPerPage = 12;

  @override
  void didUpdateWidget(covariant _MobileStockTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tableData != widget.tableData) {
      _currentPage = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tableData.isEmpty) {
      return const Center(child: Text('No historical data available'));
    }

    final currencyFormat = NumberFormat.simpleCurrency();
    final compactVolume = NumberFormat.compact();

    final int startIndex = _currentPage * _rowsPerPage;
    final int endIndex = (startIndex + _rowsPerPage < widget.tableData.length)
        ? startIndex + _rowsPerPage
        : widget.tableData.length;
    final List<StockRow> pageData = widget.tableData.sublist(
      startIndex,
      endIndex,
    );
    final int totalPages = (widget.tableData.length / _rowsPerPage).ceil();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkCardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Row(
            children: [
              Icon(Icons.table_chart, color: AppTheme.secondaryColor, size: 17),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Full Stock Data for ${widget.ticker} (Latest First)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontally scrollable table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 540, // guarantees all 6 columns are visible
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.3), // Date
                  1: FlexColumnWidth(1.2), // Close
                  2: FlexColumnWidth(1.0), // Open
                  3: FlexColumnWidth(1.0), // High
                  4: FlexColumnWidth(1.0), // Low
                  5: FlexColumnWidth(1.0), // Volume
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  // Header row
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    children: [
                      _headerCell('Date', left: true),
                      _headerCell('Close'),
                      _headerCell('Open'),
                      _headerCell('High'),
                      _headerCell('Low'),
                      _headerCell('Volume'),
                    ],
                  ),
                  // Data rows
                  ...List.generate(pageData.length, (pageIndex) {
                    final int actualIndex = startIndex + pageIndex;
                    final row = pageData[pageIndex];
                    final double? prevClose =
                        (actualIndex < widget.tableData.length - 1)
                        ? widget.tableData[actualIndex + 1].close
                        : null;
                    final isEven = pageIndex.isEven;

                    return TableRow(
                      decoration: BoxDecoration(
                        color: isEven
                            ? Colors.white.withValues(alpha: 0.01)
                            : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withValues(alpha: 0.03),
                          ),
                        ),
                      ),
                      children: [
                        _dataCell(
                          Text(
                            row.date,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimaryDark,
                            ),
                          ),
                          left: true,
                        ),
                        _closePriceCell(row.close, prevClose, currencyFormat),
                        _dataCell(
                          Text(
                            currencyFormat.format(row.open),
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.textSecondaryDark,
                            ),
                          ),
                        ),
                        _dataCell(
                          Text(
                            currencyFormat.format(row.high),
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.textSecondaryDark,
                            ),
                          ),
                        ),
                        _dataCell(
                          Text(
                            currencyFormat.format(row.low),
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.textSecondaryDark,
                            ),
                          ),
                        ),
                        _dataCell(
                          Text(
                            compactVolume.format(row.volume),
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.textSecondaryDark,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Pagination controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${startIndex + 1}–$endIndex of ${widget.tableData.length}',
                style: const TextStyle(
                  color: AppTheme.textSecondaryDark,
                  fontSize: 11,
                ),
              ),
              Row(
                children: [
                  _pageButton(
                    icon: Icons.chevron_left,
                    enabled: _currentPage > 0,
                    onTap: () => setState(() => _currentPage--),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '${_currentPage + 1} / $totalPages',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _pageButton(
                    icon: Icons.chevron_right,
                    enabled: _currentPage < totalPages - 1,
                    onTap: () => setState(() => _currentPage++),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String label, {bool left = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        label,
        textAlign: left ? TextAlign.left : TextAlign.right,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondaryDark,
        ),
      ),
    );
  }

  Widget _dataCell(Widget child, {bool left = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
      child: Align(
        alignment: left ? Alignment.centerLeft : Alignment.centerRight,
        child: child,
      ),
    );
  }

  Widget _closePriceCell(double current, double? prev, NumberFormat fmt) {
    final priceText = Text(
      fmt.format(current),
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimaryDark,
      ),
    );

    if (prev == null || current == prev) {
      return _dataCell(priceText);
    }

    final isUp = current > prev;
    final color = isUp ? AppTheme.accentColor : AppTheme.warningColor;

    return _dataCell(
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          priceText,
          const SizedBox(width: 3),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: color,
              size: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
