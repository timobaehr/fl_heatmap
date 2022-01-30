import 'package:flutter/material.dart';

import 'heatmap_style.dart';

class HeatmapData {
  const HeatmapData(
      {required this.columns,
      required this.rows,
      required this.items,
      this.selectedColor = Colors.red,
      this.colorPalette = colorPaletteGreen});

  final int columns;
  final int rows;

  /// The color palette is used to show the difference between the values.
  /// There should be at least 2 colors, otherwise the heatmap rects have all
  /// the same color. The more colors are inside this palette, the more value
  /// classes are created automatically.
  final List<Color> colorPalette;

  final Color selectedColor;

  final List<HeatmapItem> items;

  List<Rect> get rects => [];
}

class HeatmapItem {
  const HeatmapItem(
      {required this.value, this.unit, this.xAxisLabel, this.yAxisLabel});

  final double value;

  final String? unit;

  /// Label on the bottom horizontal axis, e.g. the month
  final String? xAxisLabel;

  /// Label on the left vertical axis, e.g. the year
  final String? yAxisLabel;
}
