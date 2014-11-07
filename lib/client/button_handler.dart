library pingpong.button_handler;

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'common.dart';

// Hold down for timeframe
const _undoTimeframe = const Duration(milliseconds: 400);

//Press and release and press again within timeframe
const _badServeTimeframe = const Duration(milliseconds: 500);

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
  final Team primaryTeam;
  final bool forTeam;

  Button(this.primaryTeam, {this.forTeam}){
   if(forTeam == null) throw "Button missing 'forTeam'";
  }

  Button.fromJson(Map json) :
    primaryTeam = new Team(json['primaryTeam']),
    forTeam = json['forTeam'];

  bool operator==(Button other){
    if(identical(this, other)) return true;
    return primaryTeam == other.primaryTeam && forTeam == other.forTeam;
  }

  int get hashCode => primaryTeam.hashCode * 17 + forTeam.hashCode;
  Map toJson()=> {'primaryTeam': primaryTeam.index, 'forTeam': forTeam};

  Team get effectiveTeam => forTeam ? primaryTeam : primaryTeam.other;
}

Map get _defaultConfiguration => {
  'Q': new Button(T0, forTeam: true),
  'W': new Button(T0, forTeam: false),
  'O': new Button(T1, forTeam: true),
  'P': new Button(T1, forTeam: false),
};

Map _processStoredConfiguration(){
  Map stored = JSON.decode(window.localStorage['shortcuts']);
  return new Map.fromIterables(stored.keys, stored.values.map((x)=> new Button.fromJson(x)));
}

void _saveToStorage(Map<String, Button> map){
  window.localStorage['shortcuts'] = JSON.encode(map);
}

class KeyHandler{
  Timer _undoTimer;
  Timer _scoreTimer;
  Button _lastButton;    // detection for bad serve
  Button _currentButton; // Prevents Repetition
  Button _activeButton;  // Button event fired on
  StreamSubscription _keyDownSub;
  StreamSubscription _keyUpSub;

  final _undo = new StreamController.broadcast();
  final _badServe = new StreamController.broadcast();
  final _score = new StreamController<PlayerKeyEvent>.broadcast();

  Stream get onUndo => _undo.stream;
  Stream get onBadServe => _badServe.stream;
  Stream get onScore => _score.stream;

  KeyHandler(){
    ButtonMappings.init();
    _keyDownSub = document.onKeyDown.listen(_onKeyDown);
    _keyUpSub = document.onKeyUp.listen(_onKeyUp);
  }

  void close(){
    _keyDownSub.cancel();
    _keyUpSub.cancel();
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
      _badServe.add(null);
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
    _score.add(new PlayerKeyEvent(_activeButton.effectiveTeam));
    _clearAllTimeouts();
  }

  void _onUndoTimeout(){
    _undo.add(null);
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
  final Team team;
  PlayerKeyEvent(this.team);
}
