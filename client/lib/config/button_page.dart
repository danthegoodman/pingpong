library button_page;

import 'dart:html';
import 'package:pingpong/common.dart';

final List _fields = [];

class ButtonPage extends ManagerPage{
  Element element;

  ButtonPage(){
    element = query("#buttonSection");
    ButtonMappings.init();

    for(int team in [0,1])
      for(int pos in [0,1])
        for(int ndx in [0,1])
          _fields.add(new ButtonField(team, pos, ndx));
  }
}

class ButtonField{
  Button button;
  InputElement _el;

  ButtonField(team, position, index){
    button = new Button(team, position, index);

    _el = query("#sc$team$position$index");
    _el.onClick.listen(_onClick);
    _el.onKeyDown.listen(_onKeyDown);

    String key = ButtonMappings.findKeyForButton(button);
    _el.value = key != null ? key : "";
  }

  _onClick(q){
    _el.focus();
  }

  _onKeyDown(KeyboardEvent e){
    _el.value = ButtonMappings.findKeyForEvent(e);
    _saveShortcuts();
  }

  String get key => _el.value;
}

_saveShortcuts(){
  var map = {};
  for(ButtonField f in _fields){
    if(f.key.isNotEmpty) map[f.key] = f.button;
  }
  ButtonMappings.update(map);
}
