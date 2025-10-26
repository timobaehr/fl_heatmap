import 'package:flutter/foundation.dart';
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is HeatmapData &&
        listEquals(other.columns, columns) &&
        listEquals(other.rows, rows) &&
        listEquals(other.colorPalette, colorPalette) &&
        other.selectedColor == selectedColor &&
        listEquals(other.items, items) &&
        other.radius == radius;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(columns),
        Object.hashAll(rows),
        Object.hashAll(colorPalette),
        selectedColor,
        Object.hashAll(items),
        radius,
      );
}

class HeatmapItem {
  const HeatmapItem({
    required this.value,
    this.alternativeValue,
    this.unit,
    this.xAxisLabel,
    this.yAxisLabel,
    this.style = HeatmapItemStyle.filled,
  });

  /// Value used for cell color
  final double value;

  /// Optional alternative value that is not used for cell color
  final double? alternativeValue;

  final String? unit;

  final HeatmapItemStyle style;

  /// Label on the bottom horizontal axis, e.g. the month
  final String? xAxisLabel;

  /// Label on the left vertical axis, e.g. the year
  final String? yAxisLabel;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is HeatmapItem &&
        other.value == value &&
        other.alternativeValue == alternativeValue &&
        other.unit == unit &&
        other.style == style &&
        other.xAxisLabel == xAxisLabel &&
        other.yAxisLabel == yAxisLabel;
  }

  @override
  int get hashCode => Object.hash(
        value,
        alternativeValue,
        unit,
        style,
        xAxisLabel,
        yAxisLabel,
      );
}

enum HeatmapItemStyle {
  /// Completely filled
  filled,

  /// Hatched: A background with stripes, in German "schraffiert"
  hatched,
}
