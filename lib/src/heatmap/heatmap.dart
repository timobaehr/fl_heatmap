import 'package:flutter/material.dart';

import 'heatmap_painter.dart';

class Heatmap extends StatefulWidget {
  const Heatmap({Key? key}) : super(key: key);

  @override
  _HeatmapState createState() => _HeatmapState();
}

class _HeatmapState extends State<Heatmap> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    const double marginTop = 10;
    const double marginLeft = 10;
    const double sizeOfRect = 20;
    const double margin = 4;

    final List<Rect> rects = [
      for (int i = 0; i < 12; i++)
        Rect.fromLTWH(marginLeft + sizeOfRect * i + margin * i, marginTop,
            sizeOfRect, sizeOfRect),
    ];

    return Listener(
      onPointerDown: (PointerDownEvent event) {
        /// find the clicked cell
        final RenderBox referenceBox = context.findRenderObject() as RenderBox;
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
  }
}
