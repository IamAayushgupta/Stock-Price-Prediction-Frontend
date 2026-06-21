import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/stock_data.dart';
import '../theme/app_theme.dart';

class PredictionChart extends StatelessWidget {
  final StockData stockData;

  const PredictionChart({super.key, required this.stockData});

  @override
  Widget build(BuildContext context) {
    final predictions = stockData.predictions;
    final dates = predictions.dates;
    final actual = predictions.actual;
    final predicted = predictions.predicted;

    if (actual.isEmpty || predicted.isEmpty) {
      return Center(
        child: Text(
          "Not enough data to run LSTM model prediction.\nNeed at least 100 days of history.",
          textAlign: TextAlign.center,
          style: TextStyle(height: 1.5, fontSize: 14.sp),
        ),
      );
    }

    // Downsample to max 100 points for performance.
    // Guard: interval must be >= 1 to avoid an infinite for-loop when dataSize is 0.
    final int dataSize = actual.length;
    final int interval = dataSize <= 1 ? 1 : (dataSize / 100).ceil();

    List<FlSpot> actualSpots = [];
    List<FlSpot> predictedSpots = [];

    for (int i = 0; i < dataSize; i += interval) {
      final double x = i.toDouble();
      actualSpots.add(FlSpot(x, actual[i]));
      predictedSpots.add(FlSpot(x, predicted[i]));
    }

    return Column(
      children: [
        // Legend Row
        Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem("Actual Price", AppTheme.accentColor),
              SizedBox(width: 16.w),
              _buildLegendItem("LSTM Forecast", AppTheme.warningColor),
            ],
          ),
        ),
        // Chart Area
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 20.w, top: 12.h, left: 8.w, bottom: 8.h),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withValues(alpha: 0.02),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30.h,
                      interval: (dataSize / 5).toDouble(),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < dates.length) {
                          final parts = dates[index].split('-');
                          if (parts.length >= 2) {
                            return Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text(
                                "${parts[1]}/${parts[0].substring(2)}",
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11.sp),
                              ),
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60.w,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: Text(
                            "\$${value.toStringAsFixed(0)}",
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11.sp),
                            textAlign: TextAlign.end,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => AppTheme.darkCardBackground.withValues(alpha: 0.95),
                    tooltipBorder: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final index = barSpot.x.toInt();
                        final dateStr = (index >= 0 && index < dates.length) ? dates[index] : '';
                        final isActual = barSpot.barIndex == 0;

                        return LineTooltipItem(
                          "$dateStr\n${isActual ? 'Actual' : 'LSTM'}: \$${barSpot.y.toStringAsFixed(2)}",
                          TextStyle(
                            color: isActual ? AppTheme.accentColor : AppTheme.warningColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  // Actual Line
                  LineChartBarData(
                    spots: actualSpots,
                    isCurved: true,
                    color: AppTheme.accentColor,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.accentColor.withValues(alpha: 0.04),
                    ),
                  ),
                  // Predicted Line
                  LineChartBarData(
                    spots: predictedSpots,
                    isCurved: true,
                    color: AppTheme.warningColor,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.warningColor.withValues(alpha: 0.02),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.r,
            height: 8.r,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
