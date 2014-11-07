part of pingpong.config;

class ButtonPage extends ManagerPage{
  final _fields = <ButtonField>[];

  ButtonPage(){
    element.id = "buttonPage";
    element.innerHtml = """
      <h1>Keyboard Shortcuts for the Score Keeper</h1>
      <aside>These will only affect this machine</aside>
      <aside>Click on the box and press the desired button</aside>
      <aside>Left and Right when facing the score machine</aside>
    """;

    _fields
      ..add(new ButtonField(new Button(T0, forTeam:true)))
      ..add(new ButtonField(new Button(T0, forTeam:false)))
      ..add(new ButtonField(new Button(T1, forTeam:true)))
      ..add(new ButtonField(new Button(T1, forTeam:false)));

    element.children.addAll(_fields.map((f)=> f.el));
    element.onKeyDown.listen(_saveShortcuts);
  }

  _saveShortcuts(_){
    var map = new Map.fromIterable(_fields, key: (f)=> f.key, value: (f)=> f.button);
    ButtonMappings.update(map);
  }
}

class ButtonField{
  final el = new DivElement()..className='key';
  final _input = new SubmitButtonInputElement();
  final Button button;

  ButtonField(this.button){
    var side = button.primaryTeam == T0 ? "Left" : "Right";
    var effect = button.forTeam ? "Score" : "Opponent Scores";

    el.append(new LabelElement()..text="$side Side, ${effect}");
    el.append(_input);

    _input.onClick.listen(_onClick);
    _input.onKeyDown.listen(_onKeyDown);
    _input.value = ButtonMappings.findKeyForButton(button);
  }

  _onClick(_){
    _input.focus();
  }

  _onKeyDown(KeyboardEvent e){
    _input.value = ButtonMappings.findKeyForEvent(e);
  }

  String get key => _input.value;
}

