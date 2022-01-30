import 'dart:math';

import 'package:fl_heatmap/fl_heatmap.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const rows = ['2019', '2020', '2021', '2022'];
    const columns = [
      'Jan',
      'Feb',
      'Mär',
      'Apr',
      'Mai',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Okt',
      'Nov',
      'Dez'
    ];
    final r = Random();
    const String unit = 'kWh';
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Heatmap plugin example app'),
        ),
        body: Heatmap(
            heatmapData:
                HeatmapData(rows: rows.length, columns: columns.length, items: [
          for (int row = 0; row < rows.length; row++)
            for (int col = 0; col < columns.length; col++)
              HeatmapItem(
                  value: r.nextDouble() * 6,
                  unit: unit,
                  xAxisLabel: columns[col],
                  yAxisLabel: rows[row]),
        ])),
      ),
    );
  }
}
