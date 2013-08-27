library us.kirchmeier.pingpong.scorekeeper.keyhandler;

import 'dart:html';
import 'package:pingpong/common.dart';

// Hold down for timeframe
final Duration _undoTimeframe = const Duration(milliseconds: 400);

//Press and release and press again within timeframe
final Duration _badServeTimeframe = const Duration(milliseconds: 500);

_GlobalKeyHandler _global = new _GlobalKeyHandler();

class KeyHandler {
  bool _enabled = false;
  Stream _undo;
  Stream _badServe;
  Stream _score;
  Stream _miss;

  Stream get onUndo => _undo;
  Stream get onBadServe => _badServe;
  Stream<PlayerKeyEvent> get onScore => _score;
  Stream<PlayerKeyEvent> get onMiss => _miss;

  KeyHandler(){
    _global.ensureAttached();
    _undo = _global.undoStream.stream.where(_isEnabled);
    _badServe = _global.badServeStream.stream.where(_isEnabled);
    _score = _global.scoreStream.stream.where(_isEnabled);
    _miss = _global.missStream.stream.where(_isEnabled);
  }

  _isEnabled([q])=> _enabled;

  enable() => _enabled = true;
  disable() => _enabled = false;
}

class _GlobalKeyHandler{
  bool _isAttached = false;
  Timer _undoTimer;
  Timer _scoreTimer;

  /// The current button down.
  /// No other buttons are allowed until released.
  Button _currentButton;

  /// The last button pressed and released.
  Button _lastButton;

  StreamController undoStream = new StreamController.broadcast();
  StreamController badServeStream = new StreamController.broadcast();
  StreamController<PlayerKeyEvent> scoreStream = new StreamController<PlayerKeyEvent>.broadcast();
  StreamController<PlayerKeyEvent> missStream = new StreamController<PlayerKeyEvent>.broadcast();

  _GlobalKeyHandler(){
    ButtonMappings.init();
  }

  void ensureAttached(){
    if(_isAttached) return;
    _isAttached = true;
    document.onKeyDown.listen(_onKeyDown);
    document.onKeyUp.listen(_onKeyUp);
  }

  void _onKeyDown(KeyboardEvent e){
    Button b = ButtonMappings.findByKeyboardEvent(e);
    if(b == null) return;
    if(_currentButton != null) return;

    _currentButton = b;
    if(_lastButton != null && _lastButton == b && b.index == 1){
      if(_scoreTimer == null) return;
      badServeStream.add(null);
      _clearAllTimeouts();
    } else {
      _clearAllTimeouts();
      _undoTimer = new Timer(_undoTimeframe, _onUndoTimeout);
      _scoreTimer = new Timer(_badServeTimeframe, _onScoreTimeout);
    }
  }

  void _onKeyUp(KeyboardEvent e){
    Button b = ButtonMappings.findByKeyboardEvent(e);
    if(b == null) return;
    if(_currentButton != b) return;

    bool didUndoFire = (_undoTimer == null);
    if(!didUndoFire){
      _clearUndoTimeout();
      _lastButton = b;
    }
    _currentButton = null;
  }

  void _onScoreTimeout(){
    var s = _lastButton.index == 0 ? scoreStream : missStream;
    s.add(new PlayerKeyEvent._fromButton(_lastButton));
    _clearAllTimeouts();
  }

  void _onUndoTimeout(){
    undoStream.add(null);
    _clearAllTimeouts();
  }

  void _clearAllTimeouts(){
    _clearUndoTimeout();
    if(_scoreTimer != null){
      _scoreTimer.cancel();
      _scoreTimer = null;
    }
    _lastButton = null;
  }

  void _clearUndoTimeout(){
    if(_undoTimer != null){
      _undoTimer.cancel();
      _undoTimer = null;
    }
  }
}

class PlayerKeyEvent{
  final int team;
  final int position;

  PlayerKeyEvent._fromButton(Button b):
    team = b.team,
    position = b.position;
}
