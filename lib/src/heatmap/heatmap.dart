import 'package:fl_heatmap/src/heatmap/heatmap_data.dart';
import 'package:flutter/material.dart';

import 'heatmap_painter.dart';

class Heatmap extends StatefulWidget {
  const Heatmap({Key? key, required this.heatmapData}) : super(key: key);

  final HeatmapData heatmapData;

  @override
  _HeatmapState createState() => _HeatmapState();
}

class _HeatmapState extends State<Heatmap> {
  int? _selectedIndex;
  double min = 0;
  double max = 0;

  @override
  void initState() {
    /// First get min and max
    double? min, max;
    for (final item in widget.heatmapData.items) {
      if (min == null || item.value < min) {
        min = item.value;
      }
      if (max == null || item.value > max) {
        max = item.value;
      }
    }
    if (min != null && max != null) {
      this.min = min;
      this.max = max;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final fullWidth = constraints.maxWidth;
      final fullHeight = constraints.maxHeight;
      // (428 - 10 - 10)/12 = 34

      const double marginTop = 10;
      const double marginLeft = 10;
      const double marginRight = 10;
      final double spaceForRects = fullWidth - marginLeft - marginRight;
      final double spaceForRectWithMargins = (spaceForRects +
              (spaceForRects / widget.heatmapData.columns * 0.15)) /
          widget.heatmapData.columns;

      final double sizeOfRect = spaceForRectWithMargins * 0.85;
      final double margin = spaceForRectWithMargins * 0.15;

      final List<Rect> rects = [
        for (int row = 0; row < widget.heatmapData.rows; row++)
          for (int i = 0; i < widget.heatmapData.columns; i++)
            Rect.fromLTWH(
                marginLeft + sizeOfRect * i + margin * i,
                marginTop + sizeOfRect * row + margin * row,
                sizeOfRect,
                sizeOfRect),
      ];
      final List<Color> rectColors = [
        for (final heatmapItem in widget.heatmapData.items)
          valueToColor(heatmapItem.value),
      ];

      final listener = Listener(
        onPointerDown: (PointerDownEvent event) {
          /// find the clicked cell
          final RenderBox referenceBox =
              context.findRenderObject() as RenderBox;
          final Offset offset = referenceBox.globalToLocal(event.position);
          final index = rects.lastIndexWhere((rect) => rect.contains(offset));

          setState(() {
            _selectedIndex = index;
          });
        },
        child: CustomPaint(
            painter: HeatmapPainter(
              /// Needs all clickable childs as argument
              rects: rects,
              rectColors: rectColors,
              selectedIndex: _selectedIndex,
              selectedColor: widget.heatmapData.selectedColor,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints.expand(),
            )),
      );
      return listener;
    });
  }

  Color valueToColor(double value) {
    final numberOfColorClasses = widget.heatmapData.colorPalette.length;

    /// Create color classing starting and [min] to [max]
    final diff = max - min;
    final classSize = diff / numberOfColorClasses;

    for (int i = 0; i < numberOfColorClasses; i++) {
      if (value < classSize + (i * classSize)) {
        print('value: $value -> ${widget.heatmapData.colorPalette[i]}');
        return widget.heatmapData.colorPalette[i];
      }
    }

    print(
        'value: $value, min: $min, max: $max -> ${widget.heatmapData.colorPalette[0]}');
    return widget.heatmapData.colorPalette.first;
  }
}
