import 'dart:ui';

import 'package:water_cellular_automata/util/math_util.dart';

lerpColor(Color a, Color b, double t) {
  final alpha = (lerp(a.alpha / 255, b.alpha / 255, t) * 255).toInt().clamp(0, 255);
  final red =   (lerp(a.red   / 255, b.red   / 255, t) * 255).toInt().clamp(0, 255);
  final green = (lerp(a.green / 255, b.green / 255, t) * 255).toInt().clamp(0, 255);
  final blue =  (lerp(a.blue  / 255, b.blue  / 255, t) * 255).toInt().clamp(0, 255);
  return Color.fromARGB(alpha, red, green, blue);
}