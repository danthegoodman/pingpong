library com.kirchmeier.pingpong.button_mappings;

import 'dart:html';
import 'dart:json' as json;

ButtonMappingsImpl ButtonMappings = new ButtonMappingsImpl();
Map get _defaultConfiguration => {
  'Q': '010', 'W': '011',
  'O': '100', 'P': '101',
  'Z': '000', 'X': '001',
  'N': '110', 'M': '111',
  };

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

  ///For multiple buttons
  final int index;

  Button(this.team, this.position, this.index);

  bool operator==(Button other){
    if(identical(this, other)) return true;
    return team == other.team && position == other.position && index == other.index;
  }

  int get hashCode => (team << 1) + (position) + (index << 2);
}

Map _readFromStorage(){
  var s = window.localStorage['shortcuts'];
  if(s == null || s.isEmpty) throw new Exception("No exisiting configuration");
  return json.parse(s);
}

Map _processConfiguration(Map cfg){
  Map<String, Button> result = {};
  cfg.forEach((String key, String value){
    result[key] = _parseButtonConfiguration(value);
  });
  return result;
}

Button _parseButtonConfiguration(String value){
  if(value == null || value.length < 3) throw new ArgumentError("Bad Value");
  int team = int.parse(value[0]);
  int pos = int.parse(value[1]);
  int ndx = int.parse(value[2]);
  return new Button(team, pos, ndx);
}

void _saveToStorage(Map<String, Button> map){
  Map result = {};
  map.forEach((String k, Button b){
    result[k] = "${b.team}${b.position}${b.index}";
  });
  window.localStorage['shortcuts'] = json.stringify(result);
}
