import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/stock_data.dart';
import '../theme/app_theme.dart';

class MaChart extends StatefulWidget {
  final StockData stockData;

  const MaChart({super.key, required this.stockData});

  @override
  State<MaChart> createState() => _MaChartState();
}

class _MaChartState extends State<MaChart> {
  bool showMA50 = true;
  bool showMA100 = true;
  bool showMA200 = true;

  @override
  Widget build(BuildContext context) {
    final closePrices = widget.stockData.close;
    final dates = widget.stockData.dates;
    final ma50 = widget.stockData.ma50;
    final ma100 = widget.stockData.ma100;
    final ma200 = widget.stockData.ma200;

    if (closePrices.isEmpty) return const Center(child: Text("No price data available"));

    // Downsample to max 100 points for performance.
    // Guard: interval must be >= 1 to avoid an infinite for-loop when dataSize is 0.
    final int dataSize = closePrices.length;
    final int interval = dataSize <= 1 ? 1 : (dataSize / 100).ceil();

    List<FlSpot> closeSpots = [];
    List<FlSpot> ma50Spots = [];
    List<FlSpot> ma100Spots = [];
    List<FlSpot> ma200Spots = [];

    for (int i = 0; i < dataSize; i += interval) {
      final double x = i.toDouble();
      closeSpots.add(FlSpot(x, closePrices[i]));
      if (showMA50 && i < ma50.length && ma50[i] > 0) {
        ma50Spots.add(FlSpot(x, ma50[i]));
      }
      if (showMA100 && i < ma100.length && ma100[i] > 0) {
        ma100Spots.add(FlSpot(x, ma100[i]));
      }
      if (showMA200 && i < ma200.length && ma200[i] > 0) {
        ma200Spots.add(FlSpot(x, ma200[i]));
      }
    }

    return Column(
      children: [
        // Controls Row
        Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Wrap(
            spacing: 12.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.center,
            children: [
              _buildToggleChip("Close Price", AppTheme.accentColor, true, null),
              _buildToggleChip("MA50", AppTheme.ma50Color, showMA50, (val) {
                setState(() => showMA50 = val);
              }),
              _buildToggleChip("MA100", AppTheme.ma100Color, showMA100, (val) {
                setState(() => showMA100 = val);
              }),
              _buildToggleChip("MA200", AppTheme.ma200Color, showMA200, (val) {
                setState(() => showMA200 = val);
              }),
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

                        String lineName = "Price";
                        if (barSpot.barIndex == 1) lineName = "MA50";
                        if (barSpot.barIndex == 2) lineName = "MA100";
                        if (barSpot.barIndex == 3) lineName = "MA200";

                        return LineTooltipItem(
                          "$dateStr\n$lineName: \$${barSpot.y.toStringAsFixed(2)}",
                          TextStyle(
                            color: barSpot.bar.color ?? Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  // Closing Price Line
                  LineChartBarData(
                    spots: closeSpots,
                    isCurved: true,
                    color: AppTheme.accentColor,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.accentColor.withValues(alpha: 0.05),
                    ),
                  ),
                  if (showMA50)
                    LineChartBarData(
                      spots: ma50Spots,
                      isCurved: true,
                      color: AppTheme.ma50Color,
                      barWidth: 1.5,
                      dotData: const FlDotData(show: false),
                    ),
                  if (showMA100)
                    LineChartBarData(
                      spots: ma100Spots,
                      isCurved: true,
                      color: AppTheme.ma100Color,
                      barWidth: 1.5,
                      dotData: const FlDotData(show: false),
                    ),
                  if (showMA200)
                    LineChartBarData(
                      spots: ma200Spots,
                      isCurved: true,
                      color: AppTheme.ma200Color,
                      barWidth: 1.5,
                      dotData: const FlDotData(show: false),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleChip(String label, Color color, bool selected, ValueChanged<bool>? onSelected) {
    final bool isClickable = onSelected != null;
    return GestureDetector(
      onTap: isClickable ? () => onSelected(!selected) : null,
      child: MouseRegion(
        cursor: isClickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: selected 
                ? color.withValues(alpha: 0.12) 
                : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color: selected 
                  ? color.withValues(alpha: 0.3) 
                  : Colors.white.withValues(alpha: 0.06),
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
                  color: selected ? color : Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  color: selected ? color : Colors.white.withValues(alpha: 0.5),
                  fontSize: 11.sp,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
