part of pingpong.config;


class PlayerPage extends ManagerPage{
  final Element element = querySelector("#playerPage");
  final SelectElement _players = querySelector("#players");
  final InputElement _name = querySelector("#playerName");
  final _active = new Checkbox(querySelector("#playerActive"));

  PlayerPage(){
    _players.onChange.listen(_onSelectionChange);
    _name.onChange.listen(_onNameChange);
    _active.onChange.listen(_onActiveChange);
    querySelector("#playerPage .addNew").onClick.listen(_onAddNewPlayerClick);

    PlayerManager.onLoadAll.first.then(_redrawPlayers);
  }

  Player get _currentPlayer => PlayerManager.get(int.parse(_players.value));

  _onSelectionChange(_){
    var p = _currentPlayer;
    _name.value = p.name;
    _active.value = p.active;
  }

  _onNameChange(_){
    _currentPlayer.name = _name.value;
    PlayerManager.save(_currentPlayer);
    _redrawPlayers();
  }

  _onActiveChange(_){
    _currentPlayer.active = _active.value;
    PlayerManager.save(_currentPlayer);
    _redrawPlayers();
  }

  _onAddNewPlayerClick(_){
    PlayerManager.create(new Player.brandNew()).then(_redrawPlayers);
  }

  _redrawPlayers([_]){
    var currentVal = _players.value;
    var normal = [];
    var inactive = [];

    for(var p in PlayerManager.models){
      var l = (p.active ? normal : inactive);
      var id = p.id.toString();
      l.add(new OptionElement(data: p.name, value: id, selected: id == currentVal));
    }

    _players.children
        ..clear()
        ..add(new OptGroupElement()..label = "Active"..children = normal)
        ..add(new OptGroupElement()..label = "Inactive"..children = inactive);

    if(currentVal == ""){
      _players.value = normal.first.value;
      _onSelectionChange(null);
    }
  }
}
