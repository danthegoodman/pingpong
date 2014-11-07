part of pingpong.config;

class PlayerPage extends ManagerPage{
  final _addNew = new ButtonElement()..text="Add New Player"..className="addNew";
  final _players = new SelectElement()..id="players";
  final _name = new TextInputElement()..id="playerName";
  final _active = _buildCheckbox("Active", "An inactive player cannot join a game");
  final _guest = _buildCheckbox("Guest", "An anonymous account for drifters and vagabonds");
  final _frequent = _buildCheckbox("Frequent Player", "An exalted account for the pingpong addict");

  PlayerPage(){
    var namePanel = new DivElement()
      ..append(new LabelElement()..htmlFor = "playerName"..text="Name:")
      ..append(_name);

    element
      ..id = "playerPage"
      ..innerHtml = "<h1>Update Player Information</h1>"
      ..append(_addNew)
      ..append(new DivElement()..className='playerSelector'..append(_players))
      ..append(namePanel)
      ..append(_active.el)
      ..append(_guest.el)
      ..append(_frequent.el);

    _addNew.onClick.listen(_onAddNewPlayerClick);
    _players.onChange.listen(_onSelectionChange);
    _name.onChange.listen(_onNameChange);
    _active.onChange.listen(_onActiveChange);
    _guest.onChange.listen(_onGuestChange);
    _frequent.onChange.listen(_onFrequentChange);

    _redrawPlayers("");
  }

  Player get _currentPlayer => PlayerManager.get(_players.value);

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
    PlayerManager.create(new Player.brandNew()).then((newPlayer){
      _redrawPlayers(newPlayer.id.toString());
      _onSelectionChange(null);
    });
  }

  _save(){
    PlayerManager.save(_currentPlayer);
    _redrawPlayers(_players.value);
  }

  _redrawPlayers(String idToSelect){
    var normal = [];
    var inactive = [];
    var guest = [];

    for(var p in PlayerManager.models){
      var l = p.guest  ? guest :
              p.active ? normal :
                         inactive;
      var id = p.id.toString();
      l.add(new OptionElement(data: p.name, value: id, selected: id == idToSelect));
    }

    _players.children
        ..clear()
        ..add(new OptGroupElement()..label = "Active"..children = normal)
        ..add(new OptGroupElement()..label = "Inactive"..children = inactive)
        ..add(new OptGroupElement()..label = "Guests"..children = guest);

    if(idToSelect == "" && normal.isNotEmpty){
      _players.value = normal.first.value;
      _onSelectionChange(null);
    }
  }
}

Checkbox _buildCheckbox(String title, String desc){
  return new Checkbox()
    ..el.innerHtml = "${title}<aside>${desc}</aside>";
}
