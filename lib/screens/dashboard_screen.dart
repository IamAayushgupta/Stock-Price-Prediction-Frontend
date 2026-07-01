import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../models/stock_insight.dart';
import '../widgets/ma_chart.dart';
import '../widgets/prediction_chart.dart';
import '../widgets/stock_table.dart';
import '../controllers/stock_controller.dart';
import '../widgets/kpi_card.dart';
import 'mobile_dashboard.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller is registered via Get.lazyPut in main.dart — just find it here.
    final StockController controller = Get.find<StockController>();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // ── Mobile layout (< 800 px) ──────────────────────────────────
            if (constraints.maxWidth < 800) {
              return MobileDashboard(controller: controller);
            }

            // ── Desktop / Tablet layout (≥ 800 px) — UNCHANGED ───────────
            final isDesktop = constraints.maxWidth > 900;
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header & Search
                    _buildHeader(context, controller, isDesktop),
                    SizedBox(height: 24.h),

                    Obx(() {
                      if (controller.isLoading.value) {
                        return _buildLoadingState(context);
                      } else if (controller.errorMessage.value != null) {
                        return _buildErrorState(context, controller);
                      } else if (controller.stockData.value != null) {
                        return _buildDashboardGrid(context, controller, isDesktop);
                      } else {
                        return const Center(child: Text("Enter a stock symbol to get started"));
                      }
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, StockController controller, bool isDesktop) {
    final searchWidget = SizedBox(
      width: isDesktop ? 320.w : double.infinity,
      child: TextField(
        controller: controller.searchController,
        onSubmitted: (_) => controller.fetchData(),
        textCapitalization: TextCapitalization.characters,
        style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: "Enter Ticker (e.g. AAPL, TSLA)",
          prefixIcon: Icon(Icons.search, size: 18.r, color: AppTheme.textSecondaryDark),
          suffixIcon: Padding(
            padding: EdgeInsets.all(4.r),
            child: SizedBox(
              width: 38.r,
              height: 38.r,
              child: IconButton(
                onPressed: controller.fetchData,
                icon: Icon(Icons.arrow_forward, size: 16.r),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          filled: true,
          fillColor: AppTheme.darkCardBackground.withValues(alpha: 0.6),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
        ),
      ),
    );

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: 'app_logo',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 48.r,
                    height: 48.r,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Stock Prediction",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Deep Learning LSTM Forecasting Dashboard",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
                  ),
                ],
              ),
            ],
          ),
          searchWidget,
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: 'app_logo',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.r),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 40.r,
                    height: 40.r,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Stock Prediction",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26.sp),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Deep Learning LSTM Forecasting Dashboard",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13.sp),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          searchWidget,
        ],
      );
    }
  }

  Widget _buildLoadingState(BuildContext context) {
    return SizedBox(
      height: 400.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryColor, strokeWidth: 4.r),
            SizedBox(height: 20.h),
            Text(
              "Fetching real-time stock data and running LSTM inference...",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, StockController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppTheme.warningColor, size: 48.r),
          SizedBox(height: 16.h),
          Text(
            "An Error Occurred",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.warningColor, fontSize: 20.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            controller.errorMessage.value ?? "Unknown error",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14.sp),
          ),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: controller.fetchData,
            icon: Icon(Icons.refresh, size: 18.r),
            label: Text("Try Again", style: TextStyle(fontSize: 14.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningColor, 
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
        ],
      ),
    );
  }

  List<StockInsight> _generateDynamicInsights(StockController controller) {
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
          insights.add(StockInsight(
            title: "Bullish Momentum",
            description: "${controller.currentTicker.value} is trading ${pctDiff.toStringAsFixed(1)}% above its 50-day moving average (\$${ma50Last.toStringAsFixed(2)}), indicating strong short-term upward momentum.",
            icon: Icons.trending_up,
            color: AppTheme.accentColor,
          ));
        } else {
          insights.add(StockInsight(
            title: "Bearish Momentum",
            description: "${controller.currentTicker.value} is trading ${pctDiff.abs().toStringAsFixed(1)}% below its 50-day moving average (\$${ma50Last.toStringAsFixed(2)}), suggesting a short-term downward phase.",
            icon: Icons.trending_down,
            color: AppTheme.warningColor,
          ));
        }
      }
    }

    // 2. Moving Average Crossover (Golden/Death Cross)
    if (data.ma50.isNotEmpty && data.ma200.isNotEmpty) {
      final double ma50Last = data.ma50.last;
      final double ma200Last = data.ma200.last;
      if (ma50Last > 0 && ma200Last > 0) {
        if (ma50Last >= ma200Last) {
          insights.add(StockInsight(
            title: "Golden Cross Alert",
            description: "The 50-day moving average (\$${ma50Last.toStringAsFixed(2)}) is positioned above the 200-day moving average (\$${ma200Last.toStringAsFixed(2)}), indicating a long-term bullish trend.",
            icon: Icons.swap_calls,
            color: AppTheme.accentColor,
          ));
        } else {
          insights.add(StockInsight(
            title: "Death Cross Alert",
            description: "The 50-day moving average (\$${ma50Last.toStringAsFixed(2)}) is below the 200-day moving average (\$${ma200Last.toStringAsFixed(2)}), indicating a potential long-term bearish outlook.",
            icon: Icons.swap_calls,
            color: AppTheme.warningColor,
          ));
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
            insights.add(StockInsight(
              title: "LSTM Forecast",
              description: "The LSTM model predicts a bullish trajectory, forecasting a +${pctDiff.toStringAsFixed(1)}% price appreciation over the final test periods.",
              icon: Icons.auto_graph,
              color: AppTheme.accentColor,
            ));
          } else {
            insights.add(StockInsight(
              title: "LSTM Forecast",
              description: "The LSTM model predicts consolidation or downward pressure, forecasting a ${pctDiff.toStringAsFixed(1)}% price decline over the final test periods.",
              icon: Icons.auto_graph,
              color: AppTheme.warningColor,
            ));
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
      insights.add(StockInsight(
        title: "Volatility & Range",
        description: "Over the last $periods trading periods, price fluctuated between \$${minPrice.toStringAsFixed(2)} and \$${maxPrice.toStringAsFixed(2)} (a ${volatilityPct.toStringAsFixed(1)}% spread).",
        icon: Icons.radar,
        color: AppTheme.ma100Color,
      ));
    }
    
    insights.add(StockInsight(
      title: "Inference Source",
      description: "Predictions are run dynamically via a client-side ONNX LSTM network utilizing real-time Yahoo Finance data.",
      icon: Icons.info_outline,
      color: AppTheme.textSecondaryDark,
    ));

    return insights;
  }

  Widget _buildDashboardGrid(BuildContext context, StockController controller, bool isDesktop) {
    final data = controller.stockData.value!;
    final double latestClose = data.close.isNotEmpty ? data.close.last : 0.0;
    
    // Calculate basic daily metrics
    double change = 0.0;
    double changePercent = 0.0;
    if (data.close.length >= 2) {
      final double prevClose = data.close[data.close.length - 2];
      change = latestClose - prevClose;
      changePercent = (change / prevClose) * 100;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI Summary Cards
        LayoutBuilder(
          builder: (context, constraints) {
            final double cardWidth = isDesktop ? (constraints.maxWidth - 48.w) / 4 : (constraints.maxWidth - 16.w) / 2;
            
            final double ma50Val = data.ma50.isNotEmpty ? data.ma50.last : 0.0;
            final double ma100Val = data.ma100.isNotEmpty ? data.ma100.last : 0.0;
            final double ma200Val = data.ma200.isNotEmpty ? data.ma200.last : 0.0;
            
            String calculateVarianceSubtitle(double maValue) {
              if (maValue <= 0 || latestClose <= 0) return "N/A";
              final double variance = ((maValue - latestClose) / latestClose) * 100;
              final String sign = variance >= 0 ? "+" : "";
              return "($sign${variance.toStringAsFixed(1)}% from current)";
            }

            return Wrap(
              spacing: 16.w,
              runSpacing: 16.h,
              children: [
                HoverKpiCard(
                  title: "Latest Price",
                  value: "\$${latestClose.toStringAsFixed(2)}",
                  subtitle: "${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)} (${changePercent.toStringAsFixed(2)}%)",
                  color: change >= 0 ? AppTheme.accentColor : AppTheme.warningColor,
                  icon: Icons.currency_exchange,
                  width: cardWidth,
                ),
                HoverKpiCard(
                  title: "50-Day MA",
                  value: ma50Val > 0 ? "\$${ma50Val.toStringAsFixed(2)}" : "N/A",
                  subtitle: calculateVarianceSubtitle(ma50Val),
                  color: AppTheme.ma50Color,
                  icon: Icons.timeline,
                  width: cardWidth,
                  isMutedSubtitle: true,
                ),
                HoverKpiCard(
                  title: "100-Day MA",
                  value: ma100Val > 0 ? "\$${ma100Val.toStringAsFixed(2)}" : "N/A",
                  subtitle: calculateVarianceSubtitle(ma100Val),
                  color: AppTheme.ma100Color,
                  icon: Icons.analytics_outlined,
                  width: cardWidth,
                  isMutedSubtitle: true,
                ),
                HoverKpiCard(
                  title: "200-Day MA",
                  value: ma200Val > 0 ? "\$${ma200Val.toStringAsFixed(2)}" : "N/A",
                  subtitle: calculateVarianceSubtitle(ma200Val),
                  color: AppTheme.ma200Color,
                  icon: Icons.show_chart,
                  width: cardWidth,
                  isMutedSubtitle: true,
                ),
              ],
            );
          },
        ),
        SizedBox(height: 24.h),
        
        // Main Chart Section (Full Width)
        _buildChartSection(context, controller),
        SizedBox(height: 24.h),

        // Bottom Split Section (65% Table, 35% Insights on Desktop)
        if (isDesktop)
          SizedBox(
            height: 660.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 65,
                  child: _buildTableSection(context, controller),
                ),
                SizedBox(width: 24.w),
                Expanded(
                  flex: 35,
                  child: _buildInsightsSection(controller),
                ),
              ],
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 480.h,
                child: _buildTableSection(context, controller),
              ),
              SizedBox(height: 24.h),
              _buildInsightsSection(controller),
            ],
          ),
      ],
    );
  }

  Widget _buildChartSection(BuildContext context, StockController controller) {
    return Container(
      height: 480.h,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppTheme.darkCardBackground,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart Tabs Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                controller.activeChartIndex.value == 0 ? "Moving Averages" : "LSTM Prediction vs Actual",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16.sp),
              )),
              Row(
                children: [
                  _buildTabButton(controller, "MAs", 0),
                  SizedBox(width: 8.w),
                  _buildTabButton(controller, "LSTM", 1),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),
          // Chart Body — null-safe: only render charts when data is available.
          Expanded(
            child: Obx(() {
              final data = controller.stockData.value;
              if (data == null) return const SizedBox.shrink();
              return controller.activeChartIndex.value == 0
                  ? MaChart(stockData: data)
                  : PredictionChart(stockData: data);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(StockController controller, String text, int index) {
    return Obx(() {
      final isActive = controller.activeChartIndex.value == index;
      return ElevatedButton(
        onPressed: () => controller.activeChartIndex.value = index,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? AppTheme.primaryColor : Colors.white.withValues(alpha: 0.05),
          foregroundColor: isActive ? Colors.white : Colors.white.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        ),
        child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
      );
    });
  }

  Widget _buildInsightsSection(StockController controller) {
    final insights = _generateDynamicInsights(controller);
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppTheme.darkCardBackground,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: AppTheme.secondaryColor, size: 20.r),
              SizedBox(width: 8.w),
              Text("Model Insights", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 16.h),
          ...List.generate(insights.length, (index) {
            final insight = insights[index];
            return Padding(
              padding: EdgeInsets.only(bottom: index == insights.length - 1 ? 0 : 12.h),
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: insight.color.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: insight.color.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: insight.color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        insight.icon,
                        color: insight.color,
                        size: 16.r,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insight.title,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: insight.color,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            insight.description,
                            style: TextStyle(
                              fontSize: 12.sp,
                              height: 1.4,
                              color: AppTheme.textPrimaryDark.withValues(alpha: 0.9),
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

  Widget _buildTableSection(BuildContext context, StockController controller) {
    return StockTable(
      tableData: controller.stockData.value!.tableData,
      ticker: controller.currentTicker.value,
    );
  }
}

// StockInsight class moved to lib/models/stock_insight.dart
// and is imported at the top of this file.
