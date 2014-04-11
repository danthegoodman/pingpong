part of pingpong.config;


class PlayerPage extends ManagerPage{
  final Element element = querySelector("#playerPage");
  final SelectElement _players = querySelector("#players");
  final InputElement _name = querySelector("#playerName");
  final _active = new Checkbox(querySelector("#playerActive"));
  final _guest = new Checkbox(querySelector("#playerGuest"));
  final _frequent = new Checkbox(querySelector("#playerFrequent"));

  PlayerPage(){
    _players.onChange.listen(_onSelectionChange);
    _name.onChange.listen(_onNameChange);
    _active.onChange.listen(_onActiveChange);
    _guest.onChange.listen(_onGuestChange);
    _frequent.onChange.listen(_onFrequentChange);
    querySelector("#playerPage .addNew").onClick.listen(_onAddNewPlayerClick);

    PlayerManager.onLoadAll.first.then(_redrawPlayers);
  }

  Player get _currentPlayer => PlayerManager.get(int.parse(_players.value));

  _onSelectionChange(_){
    var p = _currentPlayer;
    _name.value = p.name;
    _active.value = p.active;
    _guest.value = p.guest;
    _frequent.value = p.frequent;
  }

  _onNameChange(_){
    _currentPlayer.name = _name.value;
    _save();
  }

  _onActiveChange(_){
    _currentPlayer.active = _active.value;
    _save();
  }

  _onGuestChange(_){
    _currentPlayer.guest = _guest.value;
    _save();
  }

  _onFrequentChange(_){
    _currentPlayer.frequent = _frequent.value;
    _save();
  }

  _onAddNewPlayerClick(_){
    PlayerManager.create(new Player.brandNew()).then(_redrawPlayers);
  }

  _save(){
    PlayerManager.save(_currentPlayer);
    _redrawPlayers(null);
  }

  _redrawPlayers(_){
    var currentVal = _players.value;
    var normal = [];
    var inactive = [];
    var guest = [];

    for(var p in PlayerManager.models){
      var l = p.guest  ? guest :
              p.active ? normal :
                         inactive;
      var id = p.id.toString();
      l.add(new OptionElement(data: p.name, value: id, selected: id == currentVal));
    }

    _players.children
        ..clear()
        ..add(new OptGroupElement()..label = "Active"..children = normal)
        ..add(new OptGroupElement()..label = "Inactive"..children = inactive)
        ..add(new OptGroupElement()..label = "Guests"..children = guest);

    if(currentVal == ""){
      _players.value = normal.first.value;
      _onSelectionChange(null);
    }
  }
}
