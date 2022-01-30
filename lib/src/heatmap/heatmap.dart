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
              selectedIndex: _selectedIndex,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints.expand(),
            )),
      );
      return listener;
    });
  }
}
