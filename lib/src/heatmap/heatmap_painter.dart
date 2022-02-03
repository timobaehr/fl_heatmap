import 'package:flutter/material.dart';

import 'heatmap_data.dart';

class HeatmapPainter extends CustomPainter {
  HeatmapPainter(
      {required this.items,
      required this.selectedIndex,
      required this.selectedColor});

  final List<ViewModelItem> items;

  final int? selectedIndex;

  final Color selectedColor;

  static const double selectedBorderThickness = 3;

  @override
  void paint(Canvas canvas, Size size) {
    /// Called whenever the object needs to paint. The given [Canvas] has its
    /// coordinate space configured such that the origin is at the top left of the
    /// box. The area of the box is the size of the [size] argument.
    ///
    /// Paint operations should remain inside the given area. Graphical
    /// operations outside the bounds may be silently ignored, clipped, or not
    /// clipped. It may sometimes be difficult to guarantee that a certain
    /// operation is inside the bounds (e.g., drawing a rectangle whose size is
    /// determined by user inputs). In that case, consider calling
    /// [Canvas.clipRect] at the beginning of [paint] so everything that follows
    /// will be guaranteed to only draw within the clipped area.
    ///
    /// Implementations should be wary of correctly pairing any calls to
    /// [Canvas.save]/[Canvas.saveLayer] and [Canvas.restore], otherwise all
    /// subsequent painting on this canvas may be affected, with potentially
    /// hilarious but confusing results.
    ///
    /// To paint text on a [Canvas], use a [TextPainter].
    ///
    /// To paint an image on a [Canvas]:
    ///
    /// 1. Obtain an [ImageStream], for example by calling [ImageProvider.resolve]
    ///    on an [AssetImage] or [NetworkImage] object.
    ///
    /// 2. Whenever the [ImageStream]'s underlying [ImageInfo] object changes
    ///    (see [ImageStream.addListener]), create a new instance of your custom
    ///    paint delegate, giving it the new [ImageInfo] object.
    ///
    /// 3. In your delegate's [paint] method, call the [Canvas.drawImage],
    ///    [Canvas.drawImageRect], or [Canvas.drawImageNine] methods to paint the
    ///    [ImageInfo.image] object, applying the [ImageInfo.scale] value to
    ///    obtain the correct rendering size.

    final paintSelected = Paint()..color = selectedColor;
    for (int i = 0; i < items.length; i++) {
      final rect = items[i].rect;
      if (i == selectedIndex) {
        final paint = Paint()..color = items[i].color;
        canvas.drawRect(rect, paintSelected);
        final left = rect.left + selectedBorderThickness;
        final top = rect.top + selectedBorderThickness;
        final width = rect.width - 2 * selectedBorderThickness;
        final height = rect.height - 2 * selectedBorderThickness;
        canvas.drawRect(Rect.fromLTWH(left, top, width, height), paint);
        _drawOverlay(
            style: items[i].style,
            canvas: canvas,
            left: left,
            top: top,
            width: width,
            height: height);
      } else {
        final paint = Paint()
          ..color = items.length == i ? Colors.transparent : items[i].color;
        canvas.drawRect(rect, paint);
        _drawOverlay(
            style: items[i].style,
            canvas: canvas,
            left: rect.left,
            top: rect.top,
            width: rect.width,
            height: rect.height);
      }
    }
  }

  void _drawOverlay(
      {required HeatmapItemStyle? style,
      required Canvas canvas,
      required double left,
      required double top,
      required double width,
      required double height}) {
    switch (style) {
      case HeatmapItemStyle.filled:
        break;
      case HeatmapItemStyle.hatched:
        final p1 = Offset(left, top);
        final p2 = Offset(left + width, top + height);
        final paint = Paint()
          ..color = const Color(0x88EFEFEF)
          ..strokeWidth = width * 0.2;
        canvas.drawLine(p1, p2, paint);

        final p3 = Offset(left + 0.5 * width, top);
        final p4 = Offset(left + width, top + 0.5 * height);
        canvas.drawLine(p3, p4, paint);

        final p5 = Offset(left, top + width * 0.5);
        final p6 = Offset(left + 0.5 * width, top + height);
        canvas.drawLine(p5, p6, paint);
        break;
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant HeatmapPainter oldDelegate) {
    /// Called whenever a new instance of the custom painter delegate class is
    /// provided to the [RenderCustomPaint] object, or any time that a new
    /// [CustomPaint] object is created with a new instance of the custom painter
    /// delegate class (which amounts to the same thing, because the latter is
    /// implemented in terms of the former).
    ///
    /// If the new instance represents different information than the old
    /// instance, then the method should return true, otherwise it should return
    /// false.
    ///
    /// If the method returns false, then the [paint] call might be optimized
    /// away.
    ///
    /// It's possible that the [paint] method will get called even if
    /// [shouldRepaint] returns false (e.g. if an ancestor or descendant needed to
    /// be repainted). It's also possible that the [paint] method will get called
    /// without [shouldRepaint] being called at all (e.g. if the box changes
    /// size).
    ///
    /// If a custom delegate has a particularly expensive paint function such that
    /// repaints should be avoided as much as possible, a [RepaintBoundary] or
    /// [RenderRepaintBoundary] (or other render object with
    /// [RenderObject.isRepaintBoundary] set to true) might be helpful.
    ///
    /// The `oldDelegate` argument will never be null.
    return oldDelegate.selectedIndex != selectedIndex;
  }
}

class ViewModelItem {
  const ViewModelItem({
    required this.item,
    required this.rect,
    required this.colorPalette,
    required this.min,
    required this.max,
  });

  final HeatmapItem? item;

  final List<Color> colorPalette;

  final double min;
  final double max;

  final Rect rect;

  Color get color => _valueToColor(item?.value);

  HeatmapItemStyle? get style => item?.style;

  Color _valueToColor(double? value) {
    if (value == null) {
      return Colors.transparent;
    }
    final numberOfColorClasses = colorPalette.length;

    /// Create color classing starting and [min] to [max]
    final diff = max - min;
    final classSize = diff / numberOfColorClasses;

    if (value == min) {
      return colorPalette[0];
    }
    for (int i = 1; i < numberOfColorClasses; i++) {
      if (value <= min + (i * classSize)) {
        return colorPalette[i];
      } else if (value > (classSize * i) && i == numberOfColorClasses - 1) {
        return colorPalette.last;
      }
    }

    return colorPalette.first;
  }
}
