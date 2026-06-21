import 'package:flutter/material.dart';

/// A single insight item surfaced by the model insights panel.
class StockInsight {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const StockInsight({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
