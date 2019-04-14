import 'dart:math' as Math;
import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:water_cellular_automata/components/button.dart';
import 'package:water_cellular_automata/components/fps_counter.dart';
import 'package:water_cellular_automata/components/grid.dart';
import 'package:water_cellular_automata/input.dart';

class GameApp extends BaseGame {
  Size size;

  Grid grid;

  GameApp() {
    add(Input.getInstance());
    add(FpsCounter(5, 25, 22));

    grid = Grid();
    add(grid);

    final buttonSize = 40.0;
    final buttonData = ButtonRenderData()
      ..setBackground(Color(0xFFB2B2B2))
      ..setTopLeft('button_top_left.png')
      ..setTop('button_top.png')
      ..setTopRight('button_top_right.png')
      ..setLeft('button_left.png')
      ..setRight('button_right.png')
      ..setBottomLeft('button_bottom_left.png')
      ..setBottom('button_bottom.png')
      ..setBottomRight('button_bottom_right.png');
    
    final blockButton = Button(
      x: 280,
      y: 20,
      width: buttonSize,
      height: buttonSize,
      iconPath: 'block.png',
      renderData: buttonData,
      callback: () => grid.inputMode = GridInputMode.block,
    );
    
    final liquidButton = Button(
      x: 330,
      y: 20,
      width: buttonSize,
      height: buttonSize,
      iconPath: 'liquid.png',
      renderData: buttonData,
      callback: () => grid.inputMode = GridInputMode.liquid,
    );

    final debugButton = Button(
      x: 280,
      y: 70,
      width: buttonSize,
      height: buttonSize,
      iconPath: 'debug.png',
      renderData: buttonData,
      callback: () => grid.toggleFlowIcons(),
    );

    final resetButton = Button(
      x: 330,
      y: 70,
      width: buttonSize,
      height: buttonSize,
      iconPath: 'reset.png',
      renderData: buttonData,
      callback: () => grid.reset(),
    );

    add(blockButton);
    add(liquidButton);
    add(debugButton);
    add(resetButton);
  }

  @override
  void resize(Size size) {
    super.resize(size);
    this.size = size;
  }

  @override
  void render(Canvas c) {
    c.drawPaint(BasicPalette.white.paint);
    super.render(c);
  }
}

// class Cell extends PositionComponent {
//   static const speed = 2;

//   double x;
//   double y;

//   Cell({
//     @required double size,
//     this.x = 0,
//     this.y = 0,
//   }) {
//     width = height = size;
//   }

//   @override
//   void resize(Size size) {
//     x = size.width / 2;
//     y = size.height / 2;
//     anchor = Anchor.center;
//   }

//   @override
//   void update(double dt) {
//     angle += dt * speed;
//     angle %= 2 * Math.pi;
//   }

//   @override
//   void render(Canvas c) {
//     prepareCanvas(c);

//     c.drawRect(Rect.fromLTWH(0, 0, width, height), BasicPalette.white.paint);
//   }
// }