import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:water_cellular_automata/components/cell.dart';
import 'package:water_cellular_automata/components/liquid_simulator.dart';
import 'package:water_cellular_automata/input.dart';
import 'package:water_cellular_automata/palette.dart';

class Grid extends PositionComponent {
  static const gridWidth = 40;
  static const gridHeight = 60;
  
  double cellSize = 10;

  double lineWidth = 0.0;

  Color lineColor = Palette.gridLine.color;

  GridInputMode inputMode = GridInputMode.block;

  bool showFlow = true;
  bool renderDownFlowingLiquid = true;
  bool renderFloatingLiquid = true;

  LiquidSimulator simulator;
  List<Cell> cells;
  List<Sprite> flowSprites;

  Cell getCell(int x, int y) => cells[y * gridWidth + x];
  void setCell(int x, int y, Cell cell) => cells[y * gridWidth + x] = cell;

  Grid() {
    flowSprites = [
      Sprite('flow_debug_icons/00.png'),
      Sprite('flow_debug_icons/01.png'),
      Sprite('flow_debug_icons/02.png'),
      Sprite('flow_debug_icons/03.png'),
      Sprite('flow_debug_icons/04.png'),
      Sprite('flow_debug_icons/05.png'),
      Sprite('flow_debug_icons/06.png'),
      Sprite('flow_debug_icons/07.png'),
      Sprite('flow_debug_icons/08.png'),
      Sprite('flow_debug_icons/09.png'),
      Sprite('flow_debug_icons/10.png'),
      Sprite('flow_debug_icons/11.png'),
      Sprite('flow_debug_icons/12.png'),
      Sprite('flow_debug_icons/13.png'),
      Sprite('flow_debug_icons/14.png'),
      Sprite('flow_debug_icons/15.png'),
    ];

    createGrid();

    simulator = LiquidSimulator();
    simulator.initialize(cells);
  }

  void createGrid() {
    cells = List(gridWidth * gridHeight);

    width = gridWidth * cellSize;
    height = gridHeight * cellSize;

    double px, py;
    for (int x = 0; x < gridWidth; x++) {
      for (int y = 0; y < gridHeight; y++) {
        px = x * cellSize + this.x;
        py = y * cellSize + this.y;

        Cell cell = Cell()
          ..set(
            x: x,
            y: y,
            position: Position(px, py),
            cellSize: cellSize,
            showFlow: showFlow,
            flowSprites: flowSprites,
            renderDownFlowingLiquid: renderDownFlowingLiquid,
            renderFloatingLiquid: renderFloatingLiquid,
          );

        if (x == 0 || y == 0 || x == gridWidth - 1 || y == gridHeight - 1) {
          cell.type = CellType.solid;
        }

        setCell(x, y, cell);
      }
    }

    updateNeighbors();
  }

  void toggleFlowIcons() {
    showFlow = !showFlow;

    for (int x = 1; x < gridWidth - 1; x++) {
      for (int y = 1; y < gridHeight - 1; y++) {
        getCell(x, y).set(showFlow: showFlow);
      }
    }
  }
  
  void reset() {
    for (int x = 1; x < gridWidth - 1; x++) {
      for (int y = 1; y < gridHeight - 1; y++) {
        Cell cell = getCell(x, y);
        cell.addLiquid(-cell.liquid);
        cell.type = CellType.blank;
      }
    }
  }

  void refreshGrid() {
    double px, py;
    for (int x = 0; x < gridWidth; x++) {
      for (int y = 0; y < gridHeight; y++) {
        px = x * cellSize + this.x;
        py = y * cellSize + this.y;

        getCell(x, y).set(
          x: x,
          y: y,
          position: Position(px, py),
          showFlow: showFlow,
          renderDownFlowingLiquid: renderDownFlowingLiquid,
          renderFloatingLiquid: renderFloatingLiquid,
        );
      }
    }
  }

  void updateNeighbors() {
    for (int x = 0; x < gridWidth; x++) {
      for (int y = 0; y < gridHeight; y++) {
        if (x > 0) {
          getCell(x, y).left = getCell(x-1, y);
        }
        if (x < gridWidth - 1) {
          getCell(x, y).right = getCell(x+1, y);
        }
        if (y > 0) {
          getCell(x, y).top = getCell(x, y-1);
        }
        if (y < gridHeight - 1) {
          getCell(x, y).bottom = getCell(x, y+1);
        }
      }
    }
  }

  @override
  void resize(Size size) {
    x = (size.width / 2) - (width / 2);
    y = (size.height / 2) - (height / 2);

    refreshGrid();

    print('X: $x - Y: $y - Width: $width - Height: $height');
  }

  CellType targetType;

  @override
  void update(double dt) {
    
    if (inputMode == GridInputMode.block) {
      if (Input.isDragging && this.toRect().contains(Input.position.toOffset())) {
        final pos = Input.position;
        var targetX = (pos.x - this.x).toInt() ~/ cellSize;
        var targetY = (pos.y - this.y).toInt() ~/ cellSize;

        if (targetX > 0 && targetX < gridWidth - 1 && targetY > 0 && targetY < gridHeight - 1) {
          Cell cell = getCell(targetX, targetY);

          if (!Input.wasDragging) {
            targetType = cell.type == CellType.solid ? CellType.blank : CellType.solid;
          }

          cell.type = targetType;
        }
      }
    }
    else if (inputMode == GridInputMode.liquid) {
      if (Input.isDragging && this.toRect().contains(Input.position.toOffset())) {
        final pos = Input.position;
        var targetX = (pos.x - this.x).toInt() ~/ cellSize;
        var targetY = (pos.y - this.y).toInt() ~/ cellSize;

        if (targetX > 0 && targetX < gridWidth - 1 && targetY > 0 && targetY < gridHeight - 1) {
          Cell cell = getCell(targetX, targetY);
          cell.addLiquid(5);
        }
      }
    }

    simulator.simulate(cells);
    cells.forEach((cell) => cell.update(dt));
  }

  @override
  void render(Canvas c) {
    final gridPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;

    double px, py;
    for (int x = 0; x < gridWidth; x++) {
      for (int y = 0; y < gridHeight; y++) {
        px = this.x + (x * cellSize);
        py = this.y + (y * cellSize);

        if (lineWidth > 0) {
          c.drawRect(Rect.fromLTWH(px, py, cellSize, cellSize), gridPaint);
        }
      }
    }
    
    cells.forEach((cell) => cell.render(c));
  }

}

enum GridInputMode {
  block,
  liquid,
}