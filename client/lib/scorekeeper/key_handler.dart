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

  Stream get onUndo => _undo;
  Stream get onBadServe => _badServe;
  Stream<PlayerKeyEvent> get onScore => _score;

  KeyHandler(){
    _global.ensureAttached();
    _undo = _global.undoStream.stream.where(_isEnabled);
    _badServe = _global.badServeStream.stream.where(_isEnabled);
    _score = _global.scoreStream.stream.where(_isEnabled);
  }

  _isEnabled([q])=> _enabled;

  enable() => _enabled = true;
  disable() => _enabled = false;
}

class _GlobalKeyHandler{
  bool _isAttached = false;
  Timer _undoTimer;
  Timer _scoreTimer;
  String _lastChar;    // detection for bad serve
  String _currentChar; // Prevents Repetition
  String _activeChar;  // Char event fired on
  Map<String, PlayerKeyEvent> _keyLookup = {};

  StreamController undoStream = new StreamController.broadcast();
  StreamController badServeStream = new StreamController.broadcast();
  StreamController<PlayerKeyEvent> scoreStream = new StreamController<PlayerKeyEvent>.broadcast();

  _GlobalKeyHandler(){
    readShortcuts().forEach((String key, String team){
      _keyLookup[key] = new PlayerKeyEvent(int.parse(team[0]), int.parse(team[1]));
    });
  }

  void ensureAttached(){
    if(_isAttached) return;
    _isAttached = true;
    document.onKeyDown.listen(_onKeyDown);
    document.onKeyUp.listen(_onKeyUp);
  }

  void _onKeyDown(KeyboardEvent e){
    String ch = new String.fromCharCode(e.which);
    if(!_keyLookup.containsKey(ch)) return;
    if(_currentChar != null) return;

    _currentChar = ch;
    _activeChar = ch;
    if(_lastChar != null){
      if(_lastChar != ch) return;
      if(_scoreTimer == null) return;
      badServeStream.add(null);
      _clearAllTimeouts();
    } else {
      _undoTimer = new Timer(_undoTimeframe, _onUndoTimeout);
      _scoreTimer = new Timer(_badServeTimeframe, _onScoreTimeout);
    }
  }

  void _onKeyUp(KeyboardEvent e){
    String ch = new String.fromCharCode(e.which);
    if(_currentChar != ch) return;

    bool didUndoFire = (_undoTimer == null);
    if(!didUndoFire){
      _clearUndoTimeout();
      _lastChar = ch;
    }
    _currentChar = null;
  }

  void _onScoreTimeout(){
    scoreStream.add(_keyLookup[_activeChar]);
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
    _lastChar = null;
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
  const PlayerKeyEvent(this.team, this.position);
}
