import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';

class HoverKpiCard extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;
  final double width;
  final bool isMutedSubtitle;

  const HoverKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.width,
    this.isMutedSubtitle = false,
  });

  @override
  State<HoverKpiCard> createState() => _HoverKpiCardState();
}

class _HoverKpiCardState extends State<HoverKpiCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: widget.width,
        transform: Matrix4.diagonal3Values(_isHovered ? 1.03 : 1.0, _isHovered ? 1.03 : 1.0, 1.0),
        transformAlignment: Alignment.center,
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppTheme.darkCardBackground,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: _isHovered
                ? widget.color.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.08),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? widget.color.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.2),
              blurRadius: _isHovered ? 24.r : 16.r,
              offset: _isHovered ? const Offset(0, 10) : const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textSecondaryDark,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.color,
                    size: 16.r,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              widget.value,
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: AppTheme.textPrimaryDark,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              widget.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: widget.isMutedSubtitle
                    ? AppTheme.textSecondaryDark.withValues(alpha: 0.6)
                    : widget.color,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
