import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:ink_page_indicator/src/src.dart';

abstract class PageIndicatorPainter<D extends IndicatorData, W extends PageIndicator, P extends PageIndicatorState>
    extends CustomPainter {
  final P parent;
  final D data;
  PageIndicatorPainter(
    this.parent,
    this.data,
  )   : shape = data.shape,
        activeShape = data.activeShape;

  IndicatorShape shape;
  IndicatorShape activeShape;

  W get widget => parent.widget;

  Size size;
  Canvas canvas;

  double get width => size.width;
  double get height => size.height;
  Offset get center => Offset(width / 2, height / 2);

  double get progress => parent.progress;
  double get page => parent.page;

  int get currentPage => parent.currentPage;
  int get nextPage => parent.nextPage;
  int get itemCount => parent.itemCount;

  double get gap => data.gap;

  Color get activeColor => data.activeColor;
  Color get inActiveColor => data.inActiveColor;

  final List<double> dots = [];
  double get currentDot => dots[currentPage];
  double get nextDot => dots[nextPage];

  @override
  void paint(Canvas canvas, Size size) {
    this.size = size;
    this.canvas = canvas;

    _ensureIndicatorsFitIntoAvailableSpace();
    _calculateIndicatorPositions();
  }

  void _ensureIndicatorsFitIntoAvailableSpace() {
    final maxWidth = (width - ((itemCount - 1) * gap)) / itemCount;
    final maxHeight = height;

    IndicatorShape adjustShape(IndicatorShape shape) {
      print('$maxWidth, ${shape.width}, ${shape.isCircle}');

      if (shape.isCircle) {
        final isLarger = shape.width > maxWidth || shape.height > maxHeight;
        final circleSize = isLarger ? math.min(maxWidth, maxHeight) : null;
        return shape.copyWith(
          width: circleSize,
          height: circleSize,
        );
      }

      return shape.copyWith(
        width: shape.width > maxWidth ? maxWidth : null,
        height: shape.height > maxHeight ? maxHeight : null,
      );
    }

    shape = adjustShape(shape);
    activeShape = adjustShape(activeShape);
  }

  void _calculateIndicatorPositions() {
    dots.clear();

    final w = (itemCount * shape.width) + ((itemCount - 1) * gap);
    final left = center.dx - (w / 2);

    for (var i = 0; i < itemCount; i++) {
      final width = shape.width;
      final previous = (width * i) + (gap * i);
      final dx = left + previous + (width / 2);
      dots.add(dx);
    }
  }

  double getDxForFraction(double fraction) {
    assert(dots.isNotEmpty);

    return lerpDouble(currentDot, nextDot, fraction);
  }

  @protected
  void drawActiveDot(double p) {
    final dx = getDxForFraction(p);

    final paint = Paint()
      ..color = activeColor
      ..isAntiAlias = true;

    drawIndicator(dx, paint, activeShape);
  }

  @protected
  void drawInActiveIndicators() {
    final paint = Paint()
      ..isAntiAlias = true
      ..color = inActiveColor;

    for (var i = 0; i < dots.length; i++) {
      final dx = dots[i];
      final shape = i == nextPage ? this.shape.lerpTo(activeShape, progress) : this.shape;

      drawIndicator(dx, paint, shape);
    }
  }

  void drawIndicator(double dx, Paint paint, [IndicatorShape customShape]) {
    final shape = customShape ?? this.shape;

    final rect = Rect.fromCenter(
      center: Offset(dx, center.dy),
      width: shape.width,
      height: shape.height,
    );

    final rrect = getRRectFromRect(rect, customShape);
    canvas.drawRRect(rrect, paint);
  }

  RRect getRRectFromEndPoints(double start, double end, [IndicatorShape customShape]) {
    final from = math.min(start, end);
    final to = math.max(start, end);

    final shape = customShape ?? this.shape;
    final halfWidth = shape.width / 2;

    final rect = Rect.fromLTRB(
      from - halfWidth,
      (height / 2) - (shape.height / 2),
      to + halfWidth,
      (height / 2) + (shape.height / 2),
    );

    return getRRectFromRect(rect, customShape);
  }

  RRect getRRectFromRect(Rect rect, [IndicatorShape customShape]) {
    final borderRadius = customShape?.borderRadius ?? activeShape.borderRadius;

    return RRect.fromLTRBAndCorners(
      rect.left,
      rect.top,
      rect.right,
      rect.bottom,
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );
  }

  void drawPressurePath(
    Path path,
    Paint paint,
    List<PressureStop> stops,
  ) {
    PressurePath(
      path,
      stops,
    ).draw(
      canvas,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}