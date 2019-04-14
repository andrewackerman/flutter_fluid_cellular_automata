import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/position.dart';
import 'package:flutter/gestures.dart';

const double _defaultTapThreshold = 200000;

class Input extends Component {
  static Input _instance;
  static Input getInstance() {
    if (_instance == null) {
      _instance = Input();
    }

    return _instance;
  }

  static void bindListeners() => _instance._bindListeners();
  void _bindListeners() {
    final dragger = PanGestureRecognizer()
      ..onStart = _instance._onDragStart
      ..onUpdate = _instance._onDragUpdate
      ..onEnd = _instance._onDragEnd
      ..onDown = _instance._onDragDown
      ..onCancel = _instance._onDragCancel;

    Flame.util.addGestureRecognizer(dragger);
  }

  static void setTapThreshold(double timeInMilliseconds) => _instance._setTapThreshold(timeInMilliseconds);
  void _setTapThreshold(double timeInMilliseconds) {
    _tapThreshold = timeInMilliseconds * 1000;
  }

  static void setDebugMode(bool debug) => _instance._setDebugMode(debug);
  void _setDebugMode(bool debug) {
    _debugMode = debug;
  }

  static bool wasComponentTapped(PositionComponent component) => _instance._wasComponentTapped(component);
  bool _wasComponentTapped(PositionComponent component) {
    return _wasTapped && component.toRect().contains(_position.toOffset());
  }

  double _tapThreshold = _defaultTapThreshold;
  bool _debugMode = false;

  bool _isTapDown = false;
  bool _wasTapDown = false;

  bool _isTapUp = false;
  bool _wasTapUp = false;

  bool _wasTapped = false;
  
  bool _isDragging = false;
  bool _wasDragging = false;

  Position _position;
  Offset _dragOffset;

  static bool get isTapDown => _instance._isTapDown;
  static bool get wasTapDown => _instance._wasTapDown;

  static bool get isTapUp => _instance._isTapUp;
  static bool get wasTapUp => _instance._wasTapUp;

  static bool get wasTapped => _instance._wasTapped;
  
  static bool get isDragging => _instance._isDragging;
  static bool get wasDragging => _instance._wasDragging;

  static Position get position => _instance._position;
  static Offset get dragOffset => _instance._dragOffset;

  bool _inputWasGestureDown = false;
  bool _inputWasGestureUp = false;
  bool _inputIsDragging = false;
  Position _inputPosition;
  Offset _inputOffset;
  bool _inputChanged = false;
  double _inputDownTimeStamp = 0;
  double _inputUpTimeStamp = 0;

  void _onDragDown(DragDownDetails d) {
    _inputWasGestureDown = true;
    _inputPosition = Position(d.globalPosition.dx, d.globalPosition.dy);
    _inputDownTimeStamp = DateTime.now().microsecondsSinceEpoch.toDouble();
    _inputChanged = true;
  }

  void _onDragStart(DragStartDetails d) {
    _inputIsDragging = true;
    _inputPosition = Position(d.globalPosition.dx, d.globalPosition.dy);
    _inputChanged = true;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    _inputPosition = Position(d.globalPosition.dx, d.globalPosition.dy);
    _inputOffset = d.delta;
    _inputChanged = true;
  }

  void _onDragEnd(DragEndDetails d) {
    _inputUpTimeStamp = DateTime.now().microsecondsSinceEpoch.toDouble();
    _inputWasGestureUp = true;
    _inputIsDragging = false;
    _inputChanged = true;
  }

  void _onDragCancel() {
    _inputUpTimeStamp = DateTime.now().microsecondsSinceEpoch.toDouble();
    _inputWasGestureUp = true;
    _inputIsDragging = false;
    _inputChanged = true;
  }

  @override
  void update(double dt) {
    // Tap Down
    _wasTapDown =_isTapDown;
    _isTapDown = _inputWasGestureDown;
    _inputWasGestureDown = false;

    // Tap Up
    _wasTapUp =_isTapUp;
    _isTapUp = _inputWasGestureUp;
    _inputWasGestureUp = false;

    // Dragging
    _wasDragging = _isDragging;
    _isDragging = _inputIsDragging;

    // Tapped
    _wasTapped = _isTapUp && !_wasTapUp && (!_wasDragging || (_inputUpTimeStamp > _inputDownTimeStamp && _inputUpTimeStamp - _inputDownTimeStamp < _tapThreshold));

    // Position
    _position = _inputPosition;

    // Offset
    _dragOffset = _inputOffset;
    _inputOffset = Offset.zero;

    // Debug
    if (_debugMode && _inputChanged) {
      print({
        'isTapDown': isTapDown,
        'wasTapDown': wasTapDown,
        'isTapUp': isTapUp,
        'wasTapUp': wasTapUp,
        'wasTapped': wasTapped,
        'isDragging': isDragging,
        'wasDragging': wasDragging,
        'position': position,
        'offset': dragOffset,
      });

      _inputChanged = false;
    }
  }

  @override render(c) {}
}