import 'package:fl_heatmap/src/heatmap/heatmap_data.dart';
import 'package:flutter/material.dart';

import 'heatmap_painter.dart';

class Heatmap extends StatefulWidget {
  const Heatmap(
      {Key? key,
      required this.heatmapData,
      required this.onItemSelectedListener})
      : super(key: key);

  final HeatmapData heatmapData;

  /// [selectedItem] is null if item is unselected
  final Function(HeatmapItem? selectedItem) onItemSelectedListener;

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

      final int rows = widget.heatmapData.rows.length;
      final int columns = widget.heatmapData.columns.length;

      const double marginTop = 10;
      const double marginLeft = 10;
      const double marginRight = 10;
      final double spaceForRects = fullWidth - marginLeft - marginRight;
      final double spaceForRectWithMargins =
          (spaceForRects + (spaceForRects / columns * 0.10)) / columns;

      final double sizeOfRect = spaceForRectWithMargins * 0.90;
      final double margin = spaceForRectWithMargins * 0.10;

      final List<Rect> rects = [
        for (int row = 0; row < rows; row++)
          for (int col = 0; col < columns; col++)
            Rect.fromLTWH(
                marginLeft + sizeOfRect * col + margin * col,
                marginTop + sizeOfRect * row + margin * row,
                sizeOfRect,
                sizeOfRect),
      ];
      final List<Color> rectColors = [
        for (final heatmapItem in widget.heatmapData.items)
          valueToColor(heatmapItem.value),
      ];
      final usedHeight = marginTop + sizeOfRect * rows + margin * rows;

      final listener = Listener(
        onPointerDown: (PointerDownEvent event) {
          /// find the clicked cell
          final RenderBox referenceBox =
              context.findRenderObject() as RenderBox;
          final Offset offset = referenceBox.globalToLocal(event.position);
          final index = rects.lastIndexWhere((rect) => rect.contains(offset));

          final selectedItem =
              index == -1 ? null : widget.heatmapData.items[index];
          widget.onItemSelectedListener(selectedItem);
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
      return SizedBox(
        height: usedHeight,
        child: listener,
      );
    });
  }

  Color valueToColor(double value) {
    final numberOfColorClasses = widget.heatmapData.colorPalette.length;

    /// Create color classing starting and [min] to [max]
    final diff = max - min;
    final classSize = diff / numberOfColorClasses;

    for (int i = 0; i < numberOfColorClasses; i++) {
      if (value <= classSize + (i * classSize)) {
        return widget.heatmapData.colorPalette[i];
      } else if (value > (classSize * i) && i == numberOfColorClasses - 1) {
        return widget.heatmapData.colorPalette.last;
      }
    }

    return widget.heatmapData.colorPalette.first;
  }
}
