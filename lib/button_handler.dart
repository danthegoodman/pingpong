library pingpong.button_handler;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

// Hold down for timeframe
const _undoTimeframe = const Duration(milliseconds: 400);

//Press and release and press again within timeframe
const _badServeTimeframe = const Duration(milliseconds: 500);

_GlobalKeyHandler _global = new _GlobalKeyHandler();

class ButtonMappings {
  static Map<String, Button> _map;

  static void init(){
    try{
      _map = _processStoredConfiguration();
    } catch (ignored){
      _map = _defaultConfiguration;
    }
  }

  static void update(Map<String, Button> map) {
    _map = map;
    _saveToStorage(map);
  }

  static Button findByKeyboardEvent(KeyboardEvent e){
    return _map[findKeyForEvent(e)];
  }

  static String findKeyForEvent(KeyboardEvent e){
    return new String.fromCharCode(e.which);
  }

  static String findKeyForButton(Button b) {
    for(String k in _map.keys){
      if(_map[k] == b) return k;
    }
    return null;
  }
}

class Button {
  final int team;
  final int position;

  Button(this.team, this.position);

  bool operator==(Button other){
    if(identical(this, other)) return true;
    return team == other.team && position == other.position;
  }

  int get hashCode => (team << 1) + (position);

  String toString()=> "B(${team},$position)";
}

Map get _defaultConfiguration => {
  'Q': new Button(0, 1),
  'P': new Button(1, 0),
  'Z': new Button(0, 0),
  'M': new Button(1, 1),
};

Map _processStoredConfiguration(){
  Map stored = JSON.decode(window.localStorage['shortcuts']);
  Map<String, Button> result = {};
  stored.forEach((String key, String value){
    int team = int.parse(value[0]);
    int pos = int.parse(value[1]);
    result[key] = new Button(team, pos);
  });
  return result;
}

void _saveToStorage(Map<String, Button> map){
  Map result = {};
  map.forEach((String k, Button b){
    result[k] = "${b.team}${b.position}";
  });
  window.localStorage['shortcuts'] = JSON.encode(result);
}

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

  _isEnabled(_)=> _enabled;

  enable() => _enabled = true;
  disable() => _enabled = false;
}

class _GlobalKeyHandler{
  bool _isAttached = false;
  Timer _undoTimer;
  Timer _scoreTimer;
  Button _lastButton;    // detection for bad serve
  Button _currentButton; // Prevents Repetition
  Button _activeButton;  // Button event fired on

  StreamController undoStream = new StreamController.broadcast();
  StreamController badServeStream = new StreamController.broadcast();
  StreamController<PlayerKeyEvent> scoreStream = new StreamController<PlayerKeyEvent>.broadcast();

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
    _activeButton = b;
    if(_lastButton != null){
      if(_lastButton != b) return;
      if(_scoreTimer == null) return;
      badServeStream.add(null);
      _clearAllTimeouts();
    } else {
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
    scoreStream.add(new PlayerKeyEvent._fromButton(_activeButton));
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
  final int index;

  PlayerKeyEvent._fromButton(Button b):
    index = b.team + (b.position * 2);
}
