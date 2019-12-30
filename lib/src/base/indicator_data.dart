import 'package:flutter/material.dart';

import 'package:ink_page_indicator/src/src.dart';

abstract class IndicatorData {
  final Color activeColor;
  final Color inActiveColor;
  final double gap;
  final IndicatorShape shape;
  final IndicatorShape activeShape;
  IndicatorData({
    @required this.activeColor,
    @required this.inActiveColor,
    @required this.gap,
    @required this.shape,
    @required this.activeShape,
  });
  
  IndicatorData lerpTo(IndicatorData b, double t);
}