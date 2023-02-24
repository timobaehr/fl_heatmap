import 'package:flutter/material.dart';

import 'heatmap_style.dart';

class HeatmapData {
  const HeatmapData({
    required this.columns,
    required this.rows,
    required this.items,
    this.selectedColor = Colors.red,
    this.colorPalette = colorPaletteGreen,
    this.radius = 0.0,
  });

  final List<String> columns;
  final List<String> rows;

  /// The color palette is used to show the difference between the values.
  /// There should be at least 2 colors, otherwise the heatmap rects have all
  /// the same color. The more colors are inside this palette, the more value
  /// classes are created automatically.
  final List<Color> colorPalette;

  final Color selectedColor;

  final List<HeatmapItem> items;

  /// Rounded rect with radius or a rect without rounded edges
  final double radius;

  List<Rect> get rects => [];
}

class HeatmapItem {
  const HeatmapItem(
      {required this.value,
      this.unit,
      this.xAxisLabel,
      this.yAxisLabel,
      this.style = HeatmapItemStyle.filled});

  final double value;

  final String? unit;

  final HeatmapItemStyle style;

  /// Label on the bottom horizontal axis, e.g. the month
  final String? xAxisLabel;

  /// Label on the left vertical axis, e.g. the year
  final String? yAxisLabel;
}

enum HeatmapItemStyle {
  /// Completely filled
  filled,

  /// Hatched: A background with stripes, in German "schraffiert"
  hatched,
}
