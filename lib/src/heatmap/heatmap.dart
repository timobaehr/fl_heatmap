import 'package:flutter/material.dart';

import 'heatmap_painter.dart';

class Heatmap extends StatefulWidget {
  const Heatmap({Key? key}) : super(key: key);

  @override
  _HeatmapState createState() => _HeatmapState();
}

class _HeatmapState extends State<Heatmap> {
  final GlobalKey _paintKey = GlobalKey();
  Offset? _offset;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        final RenderBox? referenceBox =
            _paintKey.currentContext?.findRenderObject() as RenderBox?;
        final Offset? offset = referenceBox?.globalToLocal(event.position);
        if (offset != null) {
          setState(() {
            _offset = offset;
          });
        }
      },
      child: CustomPaint(
          key: _paintKey,
          painter: HeatmapPainter(offset: _offset ?? const Offset(0, 0)),
          child: ConstrainedBox(
            constraints: const BoxConstraints.expand(),
          )),
    );
  }
}
