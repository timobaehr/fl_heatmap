import 'package:fl_heatmap/src/heatmap/heatmap_data.dart';
import 'package:flutter/material.dart';

import 'heatmap_painter.dart';

class Heatmap extends StatefulWidget {
  const Heatmap(
      {Key? key,
      required this.heatmapData,
      this.showXAxisLabels = true,
      this.showYAxisLabels = true,
      this.onItemSelectedListener})
      : super(key: key);

  final HeatmapData heatmapData;

  final bool showXAxisLabels, showYAxisLabels;

  /// [selectedItem] is null if item is unselected
  final Function(HeatmapItem? selectedItem)? onItemSelectedListener;

  @override
  _HeatmapState createState() => _HeatmapState();
}

const double _borderThicknessInPercent = 0.1;

class _HeatmapState extends State<Heatmap> {
  int? _selectedIndex;
  double min = 0;
  double max = 0;
  double boxHeightWithMargin = 10;

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
    const double marginLeft = 10;
    const double marginRight = 10;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: marginLeft,
        ),

        /// y-axis labels
        if (widget.showYAxisLabels)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final rowLabel in widget.heatmapData.rows)
                RowLabel(rowLabel,
                    height: boxHeightWithMargin,
                    padding: const EdgeInsets.only(right: 4)),
            ],
          ),

        /// The heatmap
        Expanded(child: LayoutBuilder(builder: (context, constraints) {
          final fullWidth = constraints.maxWidth;

          final int rows = widget.heatmapData.rows.length;
          final int columns = widget.heatmapData.columns.length;

          final double spaceForRects = fullWidth;
          final double spaceForRectWithMargins = (spaceForRects +
                  (spaceForRects / columns * _borderThicknessInPercent)) /
              columns;

          final double sizeOfRect =
              spaceForRectWithMargins * (1.0 - _borderThicknessInPercent);
          final double margin =
              spaceForRectWithMargins * _borderThicknessInPercent;
          if (boxHeightWithMargin != sizeOfRect + margin) {
            boxHeightWithMargin = sizeOfRect + margin;
            Future.delayed(const Duration(milliseconds: 0), () {
              setState(() {});
            });
          }

          final List<Rect> rects = [
            for (int row = 0; row < rows; row++)
              for (int col = 0; col < columns; col++)
                Rect.fromLTWH(sizeOfRect * col + margin * col,
                    sizeOfRect * row + margin * row, sizeOfRect, sizeOfRect),
          ];
          final List<Color> rectColors = [
            for (final heatmapItem in widget.heatmapData.items)
              valueToColor(heatmapItem.value),
          ];
          final usedHeight = sizeOfRect * rows + margin * rows;

          final listener = Listener(
            onPointerDown: (PointerDownEvent event) {
              if (widget.onItemSelectedListener == null) {
                return;
              }

              /// find the clicked cell
              final RenderBox referenceBox =
                  context.findRenderObject() as RenderBox;
              final Offset offset = referenceBox.globalToLocal(event.position);
              final index =
                  rects.lastIndexWhere((rect) => rect.contains(offset));

              final selectedItem =
                  index == -1 ? null : widget.heatmapData.items[index];
              widget.onItemSelectedListener!(selectedItem);
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
          return Column(
            children: [
              SizedBox(
                height: usedHeight,
                child: listener,
              ),
              if (widget.showXAxisLabels)
                Row(
                  children: [
                    for (int i = 0; i < columns; i++)
                      RowLabel(widget.heatmapData.columns[i],
                          withoutMargin: i == columns - 1,
                          width: boxHeightWithMargin -
                              (i == columns - 1
                                  ? boxHeightWithMargin *
                                      _borderThicknessInPercent // size of one margin
                                  : 0)),
                  ],
                )
            ],
          );
        })),
        const SizedBox(
          width: marginRight,
        ),
      ],
    );
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

class RowLabel extends StatelessWidget {
  const RowLabel(this.text,
      {Key? key,
      this.height,
      this.width,
      this.padding,
      this.withoutMargin = true})
      : super(key: key);

  final String text;

  final bool withoutMargin;

  final double? height, width;

  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        //color: text == 'Dez' ? Colors.pink.shade200 : null,
        height: height,
        width: width,
        child: Padding(
          padding: EdgeInsets.only(
              left: padding?.left ?? 0.0,
              right: padding?.right ??
                  (width == null
                      ? 0.0
                      : withoutMargin
                          ? 0.0
                          : width! * _borderThicknessInPercent),
              top: padding?.top ?? 0.0,
              bottom: padding?.bottom ?? 0.0),
          child: Center(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.clip,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.caption,
            ),
          ),
        ));
  }
}
