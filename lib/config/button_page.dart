part of pingpong.config;

final List _fields = [];

class ButtonPage extends ManagerPage{
  Element element;

  ButtonPage(){
    element = querySelector("#buttonPage");
    _fields
      ..add(new ButtonField(0, 0))
      ..add(new ButtonField(0, 1))
      ..add(new ButtonField(1, 0))
      ..add(new ButtonField(1, 1));
  }
}

class ButtonField{
  Button button;
  InputElement _el;

  ButtonField(team, position){
    button = new Button(team, position);

    _el = querySelector("#sc$team$position");
    _el.onClick.listen(_onClick);
    _el.onKeyDown.listen(_onKeyDown);

    _el.value = ButtonMappings.findKeyForButton(button);
  }

  _onClick(_){
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
    map[f.key] = f.button;
  }
  ButtonMappings.update(map);
}
