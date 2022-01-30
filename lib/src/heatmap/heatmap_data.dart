import 'package:flutter/material.dart';

class HeatmapData {
  const HeatmapData({required this.columns, required this.rows});

  final int columns;
  final int rows;

  List<Rect> get rects => [];
}
