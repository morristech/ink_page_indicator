import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class IndicatorShape {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  IndicatorShape({
    @required this.width,
    @required this.height,
    BorderRadius borderRadius,
  })  : borderRadius = borderRadius ??
            BorderRadius.circular(
              math.min(width, height),
            );

  bool get isCircle => width == height;

  factory IndicatorShape.ofCircle(double radius) {
    return IndicatorShape(
      width: radius * 2,
      height: radius * 2,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  IndicatorShape copyWith({
    double width,
    double height,
    BorderRadius borderRadius,
  }) {
    return IndicatorShape(
      width: width ?? this.width,
      height: height ?? this.height,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  IndicatorShape lerpTo(IndicatorShape b, double t) {
    return IndicatorShape(
      width: lerpDouble(width, b.width, t),
      height: lerpDouble(height, b.height, t),
      borderRadius: BorderRadius.lerp(borderRadius, b.borderRadius, t),
    );
  }

  IndicatorShape scale(double scale) {
    return copyWith(
      width: width * scale,
      height: height * scale,
    );
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
  
    return o is IndicatorShape &&
      o.width == width &&
      o.height == height &&
      o.borderRadius == borderRadius;
  }

  @override
  int get hashCode => width.hashCode ^ height.hashCode ^ borderRadius.hashCode;

  @override
  String toString() => 'IndicatorShape width: $width, height: $height, borderRadius: $borderRadius';
}