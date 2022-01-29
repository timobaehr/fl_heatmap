import 'package:flutter/material.dart';

class HeatmapPainter extends CustomPainter {
  HeatmapPainter({required this.rects, required this.selectedIndex});

  final List<Rect> rects;

  final int? selectedIndex;

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

    final paintNotSelected = Paint()..color = Colors.green;
    final paintSelected = Paint()..color = Colors.red;
    var i = 0;
    for (final rect in rects) {
      canvas.drawRect(
          rect, i++ == selectedIndex ? paintSelected : paintNotSelected);
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
