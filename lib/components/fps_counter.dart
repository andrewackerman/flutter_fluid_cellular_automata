import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' as Material;

class FpsCounter extends PositionComponent {
  static const _sampleCount = 20;

  List<double> _samples;
  int _index = 0;

  double fontSize;
  double averageDt;

  FpsCounter(double x, double y, this.fontSize) {
    this.x = x;
    this.y = y;

    _samples = List.filled(_sampleCount, 0, growable: false);
  }

  @override
  void update(double dt) {
    _index = (_index + 1) % _sampleCount;
    _samples[_index] = dt;

    double total = 0;
    for (var sample in _samples) {
      total += sample;
    }

    averageDt = total / _samples.length;
  }

  @override
  void render(Canvas c) {
    prepareCanvas(c);

    final fps = 1 / averageDt;

    final builder = ParagraphBuilder(ParagraphStyle(fontSize: fontSize))
      ..pushStyle(TextStyle(color: Material.Colors.black))
      ..addText('FPS: ${fps.toStringAsFixed(2)}\nDelta: ${averageDt.toStringAsFixed(4)}ms');

    final paragraph = builder.build();
    paragraph.layout(ParagraphConstraints(width: 9999));

    c.drawParagraph(paragraph, Offset(0, 0));
  }
}