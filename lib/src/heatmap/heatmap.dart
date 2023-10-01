import 'dart:math';

import 'package:fl_heatmap/src/heatmap/heatmap_data.dart';
import 'package:flutter/material.dart';

import 'heatmap_painter.dart';

class Heatmap extends StatefulWidget {
  const Heatmap(
      {Key? key,
      required this.heatmapData,
      this.showXAxisLabels = true,
      this.showYAxisLabels = true,
      this.rowsVisible,
      this.showAll,
      this.showAllButtonText = 'Show all',
      this.onItemSelectedListener})
      : super(key: key);

  /// The data of the heatmap including color palette
  final HeatmapData heatmapData;

  /// Should the x axis be visible or not
  final bool showXAxisLabels;

  /// Should the y axis be visible or not
  final bool showYAxisLabels;

  /// How many rows should be visible at initial state? Leave empty, if all should be visible.
  final int? rowsVisible;

  /// If [rowsVisible] is defined, the user can request to show the hidden rows. This can be done via this widget.
  /// This is surrounded by an InkWell, so you don't have to add a listener.
  final Widget? showAll;

  /// If [rowsVisible] is defined, the user can request to show the hidden rows. A default widget is provided with
  /// shows the label "Show all". You can override this String to show you own label (e.g. with translation or
  /// different wording).
  final String showAllButtonText;

  /// [selectedItem] is null if item is unselected
  final Function(HeatmapItem? selectedItem)? onItemSelectedListener;

  @override
  _HeatmapState createState() => _HeatmapState();
}

const double _borderThicknessInPercent = 0.1;

class _HeatmapState extends State<Heatmap> {
  int? _selectedIndex;
  double minimum = 0;
  double max = 0;
  double boxHeightWithMargin = 10;

  bool showAll = true;

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
      this.minimum = min;
      this.max = max;
    }

    if (widget.rowsVisible != null) {
      showAll = false;
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
              for (int i = 0;
                  i <
                      (showAll
                          ? widget.heatmapData.rows.length
                          : min(widget.rowsVisible!, widget.heatmapData.rows.length));
                  i++)
                RowLabel(widget.heatmapData.rows[i],
                    height: boxHeightWithMargin,
                    padding: const EdgeInsets.only(right: 4)),
            ],
          ),

        /// The heatmap
        Expanded(child: LayoutBuilder(builder: (context, constraints) {
          final fullWidth = constraints.maxWidth;

          final int rows =
              showAll ? widget.heatmapData.rows.length : min(widget.rowsVisible!, widget.heatmapData.rows.length);
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

          int count = 0;
          // ignore: prefer_function_declarations_over_variables
          final itemFitsToLabels =
              (HeatmapItem item, String xAxisLabel, String yAxisLabel) {
            final result =
                item.xAxisLabel == xAxisLabel && item.yAxisLabel == yAxisLabel;
            if (result) {
              count++;
            }
            return result;
          };
          final List<Rect> rects = [
            for (int row = 0; row < rows; row++)
              for (int col = 0; col < columns; col++)
                Rect.fromLTWH(sizeOfRect * col + margin * col,
                    sizeOfRect * row + margin * row, sizeOfRect, sizeOfRect),
          ];
          final List<ViewModelItem> vmItems = [
            for (int row = 0; row < rows; row++)
              for (int col = 0; col < columns; col++)
                if (count < widget.heatmapData.items.length &&
                    itemFitsToLabels(
                        widget.heatmapData.items[count],
                        widget.heatmapData.columns[col],
                        widget.heatmapData.rows[row]))
                  ViewModelItem(
                      item: widget.heatmapData.items[count - 1],
                      colorPalette: widget.heatmapData.colorPalette,
                      min: minimum,
                      max: max,
                      rect: Rect.fromLTWH(
                          sizeOfRect * col + margin * col,
                          sizeOfRect * row + margin * row,
                          sizeOfRect,
                          sizeOfRect))
                else
                  ViewModelItem(
                      item: null,
                      colorPalette: widget.heatmapData.colorPalette,
                      min: minimum,
                      max: max,
                      rect: Rect.fromLTWH(
                          sizeOfRect * col + margin * col,
                          sizeOfRect * row + margin * row,
                          sizeOfRect,
                          sizeOfRect)),
          ];
          final usedHeight = (sizeOfRect + margin) * rows;

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

              final selectedItem = index == -1 || index > vmItems.length - 1
                  ? null
                  : vmItems[index];
              widget.onItemSelectedListener!(selectedItem?.item);
              setState(() {
                _selectedIndex = selectedItem?.item == null ? null : index;
              });
            },
            child: CustomPaint(
                painter: HeatmapPainter(
                  /// Needs all clickable children as argument
                  items: vmItems,
                  selectedIndex: _selectedIndex,
                  selectedColor: widget.heatmapData.selectedColor,
                  radius: widget.heatmapData.radius,
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
              if (!showAll && widget.rowsVisible != null)
                Center(
                  child: InkWell(
                      child: widget.showAll ??
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 16),
                            child: Text(widget.showAllButtonText.toUpperCase(),
                                style: Theme.of(context).textTheme.titleMedium),
                          ),
                      onTap: _onShowAllPressed),
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

  void _onShowAllPressed() {
    setState(() {
      showAll = true;
    });
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
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ));
  }
}
