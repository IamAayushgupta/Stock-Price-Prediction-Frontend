import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../models/stock_data.dart';
import '../theme/app_theme.dart';

class StockTable extends StatefulWidget {
  final List<StockRow> tableData;
  final String ticker;

  const StockTable({super.key, required this.tableData, required this.ticker});

  @override
  State<StockTable> createState() => _StockTableState();
}

class _StockTableState extends State<StockTable> {
  int _currentPage = 0;
  static const int _rowsPerPage = 15;

  @override
  void didUpdateWidget(covariant StockTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tableData != widget.tableData) {
      _currentPage = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tableData.isEmpty) {
      return const Center(child: Text("No historical data available"));
    }

    final currencyFormat = NumberFormat.simpleCurrency();
    final compactVolumeFormat = NumberFormat.compact();

    final int startIndex = _currentPage * _rowsPerPage;
    final int endIndex = (startIndex + _rowsPerPage < widget.tableData.length)
        ? startIndex + _rowsPerPage
        : widget.tableData.length;
    final List<StockRow> pageData = widget.tableData.sublist(startIndex, endIndex);
    final int totalPages = (widget.tableData.length / _rowsPerPage).ceil();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(24.r),
      ),
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Title Row
          Row(
            children: [
              Icon(Icons.table_chart, color: AppTheme.secondaryColor, size: 20.r),
              SizedBox(width: 8.w),
              Text(
                "Full Stock Data for ${widget.ticker} (Latest First)",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Scrollable Table inside Expanded
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: constraints.maxWidth > 600.w ? constraints.maxWidth : 600.w,
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1.2), // Date
                          1: FlexColumnWidth(1.3), // Close
                          2: FlexColumnWidth(1.0), // Open
                          3: FlexColumnWidth(1.0), // High
                          4: FlexColumnWidth(1.0), // Low
                          5: FlexColumnWidth(1.0), // Volume
                        },
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          // Header Row
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.02),
                              border: Border(
                                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                              ),
                            ),
                            children: [
                              _buildHeaderCell("Date", isNumeric: false),
                              _buildHeaderCell("Close", isNumeric: true),
                              _buildHeaderCell("Open", isNumeric: true),
                              _buildHeaderCell("High", isNumeric: true),
                              _buildHeaderCell("Low", isNumeric: true),
                              _buildHeaderCell("Volume", isNumeric: true),
                            ],
                          ),
                          // Data Rows
                          ...List.generate(pageData.length, (pageIndex) {
                            final int actualIndex = startIndex + pageIndex;
                            final row = pageData[pageIndex];
                            final double? prevRowClose = (actualIndex < widget.tableData.length - 1)
                                ? widget.tableData[actualIndex + 1].close
                                : null;

                            final isEvenRow = pageIndex.isEven;

                            return TableRow(
                              decoration: BoxDecoration(
                                color: isEvenRow 
                                    ? Colors.white.withValues(alpha: 0.01) 
                                    : Colors.transparent,
                                border: Border(
                                  bottom: BorderSide(color: Colors.white.withValues(alpha: 0.03)),
                                ),
                              ),
                              children: [
                                _buildCell(
                                  Text(
                                    row.date,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13.sp,
                                      color: AppTheme.textPrimaryDark,
                                    ),
                                  ),
                                  isNumeric: false,
                                ),
                                _buildClosePriceCell(row.close, prevRowClose, currencyFormat),
                                _buildCell(
                                  Text(
                                    currencyFormat.format(row.open),
                                    style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondaryDark),
                                  ),
                                  isNumeric: true,
                                ),
                                _buildCell(
                                  Text(
                                    currencyFormat.format(row.high),
                                    style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondaryDark),
                                  ),
                                  isNumeric: true,
                                ),
                                _buildCell(
                                  Text(
                                    currencyFormat.format(row.low),
                                    style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondaryDark),
                                  ),
                                  isNumeric: true,
                                ),
                                _buildCell(
                                  Text(
                                    compactVolumeFormat.format(row.volume),
                                    style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondaryDark),
                                  ),
                                  isNumeric: true,
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Pagination Controls
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Showing ${startIndex + 1}–$endIndex of ${widget.tableData.length}",
                  style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12.sp),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _currentPage > 0
                          ? () => setState(() => _currentPage--)
                          : null,
                      icon: Icon(Icons.chevron_left, size: 20.r),
                      color: Colors.white,
                      disabledColor: Colors.white.withValues(alpha: 0.2),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.03),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "${_currentPage + 1} / $totalPages",
                      style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      onPressed: _currentPage < totalPages - 1
                          ? () => setState(() => _currentPage++)
                          : null,
                      icon: Icon(Icons.chevron_right, size: 20.r),
                      color: Colors.white,
                      disabledColor: Colors.white.withValues(alpha: 0.2),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.03),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, {required bool isNumeric}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
      child: Text(
        label,
        textAlign: isNumeric ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13.sp,
          color: AppTheme.textSecondaryDark,
        ),
      ),
    );
  }

  Widget _buildCell(Widget child, {required bool isNumeric}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
      child: Align(
        alignment: isNumeric ? Alignment.centerRight : Alignment.centerLeft,
        child: child,
      ),
    );
  }

  Widget _buildClosePriceCell(double currentClose, double? prevClose, NumberFormat currencyFormat) {
    final priceText = Text(
      currencyFormat.format(currentClose),
      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimaryDark),
    );
    if (prevClose == null) {
      return _buildCell(
        priceText,
        isNumeric: true,
      );
    }

    final double diff = currentClose - prevClose;
    if (diff == 0) {
      return _buildCell(
        priceText,
        isNumeric: true,
      );
    }

    final isPositive = diff > 0;
    final color = isPositive ? AppTheme.accentColor : AppTheme.warningColor;
    final icon = isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down;

    return _buildCell(
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          priceText,
          SizedBox(width: 4.w),
          Container(
            padding: EdgeInsets.all(2.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Icon(icon, color: color, size: 14.r),
          ),
        ],
      ),
      isNumeric: true,
    );
  }
}
