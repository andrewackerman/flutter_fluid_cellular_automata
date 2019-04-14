import 'dart:ui';
import 'dart:math' as Math;

import 'package:flame/components/component.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:water_cellular_automata/palette.dart';
import 'package:water_cellular_automata/util/color_util.dart';

class Cell {
  int x = 0;
  int y = 0;
  Position position = Position.empty();
  double cellSize = 0;
  CellType type = CellType.blank;
  bool showFlow = false;
  bool renderDownFlowingLiquid = false;
  bool renderFloatingLiquid = false;
  List<Sprite> flowSprites;

  double liquid = 0;

  int settleCount = 0;

  bool _settled;
  bool get settled => _settled;
  set settled(bool value) {
    _settled = value;
    if (!_settled) {
      settleCount = 0;
    }
  }

  int bitMask = 0;
  List<bool> flowDirections = [false, false, false, false];
  double localScaleY = 1;

  Cell left;
  Cell top;
  Cell right;
  Cell bottom;

  Color color;

  Cell() {
    color = Palette.waterLight.color;
  }

  void set({
    int x,
    int y,
    Position position,
    double cellSize,
    CellType type,
    bool showFlow,
    List<Sprite> flowSprites,
    bool renderDownFlowingLiquid,
    bool renderFloatingLiquid,
  }) {
    if (x != null) this.x = x;
    if (y != null) this.y = y;
    if (position != null) this.position = position;
    if (cellSize != null) this.cellSize = cellSize;
    if (type != null) this.type = type;
    if (showFlow != null) this.showFlow = showFlow;
    if (flowSprites != null) this.flowSprites = flowSprites;
    if (renderDownFlowingLiquid != null) this.renderDownFlowingLiquid = renderDownFlowingLiquid;
    if (renderFloatingLiquid != null) this.renderFloatingLiquid = renderFloatingLiquid;
  }

  void setType(CellType type) {
    this.type = type;
    if (type == CellType.solid) {
      liquid = 0;
    }

    unsettleNeighbors();
  }

  void addLiquid(double amount) {
    liquid += amount;
    settled = false;
  }

  void resetFlowDirections() {
    flowDirections = [false, false, false, false];
  }

  void unsettleNeighbors() {
    if (top != null) top.settled = false;
    if (bottom != null) bottom.settled = false;
    if (left != null) left.settled = false;
    if (right != null) right.settled = false;
  }

  Rect getBounds() {
    return Rect.fromLTWH(position.x, position.y, cellSize, cellSize);
  }

  void update(double dt) {
    if (type == CellType.solid) return;

    bitMask = 0;
    if (flowDirections[FlowDirection.top])    bitMask += 1;
    if (flowDirections[FlowDirection.right])  bitMask += 2;
    if (flowDirections[FlowDirection.bottom]) bitMask += 4;
    if (flowDirections[FlowDirection.left])   bitMask += 8;

    localScaleY = Math.min(liquid, 1);

    if (!renderFloatingLiquid) {
      if (bottom != null && bottom.type != CellType.solid && bottom.liquid < 1) {
        localScaleY = 0;
      }
    } 

    if (renderDownFlowingLiquid) {
      if (type ==CellType.blank && top != null && (top.liquid > 0.01 || top.bitMask == 4)) {
        localScaleY = 1;
      }
    }

    color = lerpColor(Palette.waterLight.color, Palette.waterDark.color, liquid / 4);
  }

  void render(Canvas c) {
    if (type == CellType.solid) {
      c.drawRect(Rect.fromLTWH(position.x, position.y, cellSize, cellSize), Palette.solidTile.paint);
    } else if (liquid > 0) {

      if (!renderFloatingLiquid) {
        if (bottom != null && bottom.type != CellType.solid && bottom.liquid < 1) {
          return;
        }
      } 
      
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final h = cellSize * localScaleY;
      final y = position.y + cellSize - h;

      final rect = Rect.fromLTWH(position.x, y, cellSize, h);
      c.drawRect(rect, paint);
      
      if (showFlow) {
        // print(flowSprites);
        final sprite = flowSprites[bitMask];
        if (sprite.loaded()) {
          sprite.renderRect(c, rect);
        }
      }
    }
  }

}

enum CellType {
  blank,
  solid,
}

class FlowDirection {
  static const top = 0;
  static const right = 1;
  static const bottom = 2;
  static const left = 3;
}
