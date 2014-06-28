library com.kirchmeier.pingpong.button_mappings;

import 'dart:html';
import 'dart:convert' show JSON;

ButtonMappingsImpl ButtonMappings = new ButtonMappingsImpl();
Map get _defaultConfiguration => {'Q': '01', 'P':'10', 'Z':'00', 'M':'11'};

class ButtonMappingsImpl {
  Map<String, Button> _map;

  void init(){
    try{
      _map = _processConfiguration(_readFromStorage());
    } catch (ignored){
      _map = _processConfiguration(_defaultConfiguration);
    }
  }

  void update(Map<String, Button> map) {
    _map = map;
    _saveToStorage(map);
  }

  Button findByKeyboardEvent(KeyboardEvent e){
    return _map[findKeyForEvent(e)];
  }

  String findKeyForEvent(KeyboardEvent e){
    return new String.fromCharCode(e.which);
  }

  String findKeyForButton(Button b) {
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

  int get hashcode => (team << 1) + (position);
}

Map _readFromStorage(){
  var s = window.localStorage['shortcuts'];
  if(s == null || s.isEmpty) throw new Exception("No exisiting configuration");
  return JSON.decode(s);
}

Map _processConfiguration(Map cfg){
  Map<String, Button> result = {};
  cfg.forEach((String key, String value){
    result[key] = _parseButtonConfiguration(value);
  });
  return result;
}

Button _parseButtonConfiguration(String value){
  if(value == null || value.length < 2) throw new ArgumentError("Bad Value");
  int team = int.parse(value.substring(0,1));
  int pos = int.parse(value.substring(1,2));
  return new Button(team, pos);
}

void _saveToStorage(Map<String, Button> map){
  Map result = {};
  map.forEach((String k, Button b){
    result[k] = "${b.team}${b.position}";
  });
  window.localStorage['shortcuts'] = JSON.encode(result);
}
