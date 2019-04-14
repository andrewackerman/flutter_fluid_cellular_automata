import 'package:flame/flame.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:water_cellular_automata/game_app.dart';
import 'package:water_cellular_automata/input.dart';

void main() async {
  await Flame.util.fullScreen();
  await Flame.util.setOrientation(DeviceOrientation.portraitUp);

  final game = GameApp();
  runApp(game.widget);

  Input.bindListeners();
}