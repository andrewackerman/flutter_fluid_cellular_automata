import 'dart:ui';
import 'dart:math' as Math;

import 'package:flame/components/component.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
import 'package:water_cellular_automata/input.dart';

class Button extends PositionComponent {
  Sprite icon;
  ButtonRenderData renderData;
  void Function() callback;

  Button({
    double x,
    double y,
    double width,
    double height,
    String iconPath,
    this.renderData,
    this.callback,
  }) : this.icon = Sprite(iconPath) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }

  bool _isPressed = false;
  bool _wasPressed = false;

  @override
  void update(double dt) {
    _isPressed = Input.isTapDown && this.toRect().contains(Input.position.toOffset());

    if (_isPressed && !_wasPressed) {
      if (callback != null) {
        callback();
      }
    }
  }

  @override
  void render(Canvas c) {
    if (renderData.size == null) {
      renderData.recalculateBounds();
      if (renderData.size == null) {
        return;
      }
    }

    final rx = this.width / renderData.size.width;
    final ry = this.height / renderData.size.height;

    // Button Border
    double x, y, w, h;

    // Top-Left
    x = this.x;
    y = this.y;
    w = renderData.topLeft.size.x * rx;
    h = renderData.topLeft.size.y * ry;
    renderData.topLeft.renderRect(c, Rect.fromLTWH(x, y, w, h));

    // Top
    x = x + w;
    y = y;
    w = renderData.top.size.x * rx;
    h = renderData.top.size.y * ry;
    renderData.top.renderRect(c, Rect.fromLTWH(x, y, w, h));

    // Top-Right
    x = x + w;
    y = y;
    w = renderData.topRight.size.x * rx;
    h = renderData.topRight.size.y * ry;
    renderData.topRight.renderRect(c, Rect.fromLTWH(x, y, w, h));

    // Left
    x = this.x;
    y = y + h;
    w = renderData.left.size.x * rx;
    h = renderData.left.size.y * ry;
    renderData.left.renderRect(c, Rect.fromLTWH(x, y, w, h));

    // Right
    y = y;
    w = renderData.right.size.x * rx;
    h = renderData.right.size.y * ry;
    x = this.x + (this.width - w);
    renderData.right.renderRect(c, Rect.fromLTWH(x, y, w, h));

    // Bottom-Left
    x = this.x;
    y = y + h;
    w = renderData.bottomLeft.size.x * rx;
    h = renderData.bottomLeft.size.y * ry;
    renderData.bottomLeft.renderRect(c, Rect.fromLTWH(x, y, w, h));

    // Top
    x = x + w;
    y = y;
    w = renderData.bottom.size.x * rx;
    h = renderData.bottom.size.y * ry;
    renderData.bottom.renderRect(c, Rect.fromLTWH(x, y, w, h));

    // Top-Right
    x = x + w;
    y = y;
    w = renderData.bottomRight.size.x * rx;
    h = renderData.bottomRight.size.y * ry;
    renderData.bottomRight.renderRect(c, Rect.fromLTWH(x, y, w, h));
    
    // Background
    final paint = renderData.background.paint;
    final bgX = this.x + (renderData.topLeft.size.x * rx);
    final bgY = this.y + (renderData.topLeft.size.y * ry);
    final bgW = this.width - (renderData.left.size.x * rx) - (renderData.right.size.x * rx);
    final bgH = this.height - (renderData.top.size.y * ry) - (renderData.bottom.size.y * ry);

    c.drawRect(Rect.fromLTWH(bgX, bgY, bgW, bgH), paint);

    // Icon
    if (icon.loaded()) {
      icon.renderRect(c, Rect.fromLTWH(bgX, bgY, bgW, bgH));
    }
  }

}

class ButtonRenderData {
  Sprite topLeft;
  Sprite top;
  Sprite topRight;
  Sprite left;
  Sprite right;
  Sprite bottomLeft;
  Sprite bottom;
  Sprite bottomRight;
  PaletteEntry background;

  ButtonRenderData({
    this.topLeft,
    this.top,
    this.topRight,
    this.left,
    this.right,
    this.bottomLeft,
    this.bottom,
    this.bottomRight,
    this.background,
  });

  Size _size;
  Size get size => _size;

  void setBackground(Color color) => background = PaletteEntry(color);
  void setTopLeft(String filename) => topLeft = Sprite(filename); 
  void setTop(String filename) => top = Sprite(filename);
  void setTopRight(String filename) => topRight = Sprite(filename);
  void setLeft(String filename) => left = Sprite(filename);
  void setRight(String filename) => right = Sprite(filename);
  void setBottomLeft(String filename) => bottomLeft = Sprite(filename);
  void setBottom(String filename) => bottom = Sprite(filename);
  void setBottomRight(String filename) => bottomRight = Sprite(filename);

  bool sizeAvailable() {
    return topLeft != null && topLeft.loaded() &&
           top != null && top.loaded() &&
           topRight != null && topRight.loaded() &&
           left != null && left.loaded() &&
           right != null && right.loaded() &&
           bottomLeft != null && bottomLeft.loaded() &&
           bottom != null && bottom.loaded() &&
           bottomRight != null && bottomRight.loaded();
  }

  void recalculateBounds() async {
    if (!sizeAvailable()) {
      _size = null;
      return;
    }

    double width = Math.max(Math.max(topLeft.size.x, left.size.x), bottomLeft.size.x) + Math.max(top.size.x, bottom.size.x) + Math.max(Math.max(topRight.size.x, right.size.x), bottomRight.size.x);
    double height = Math.max(Math.max(topLeft.size.y, top.size.y), topRight.size.y) + Math.max(left.size.y, right.size.y) + Math.max(Math.max(bottomLeft.size.y, bottom.size.y), bottomRight.size.y);
    _size = Size(width, height);
  }
}