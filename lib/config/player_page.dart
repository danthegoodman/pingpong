part of pingpong.config;

final StreamController<Player> _playerDataChange = new StreamController<Player>.broadcast();

class PlayerPage extends ManagerPage{
  final Element element = querySelector("#playerSection");
  final SelectElement _players = querySelector("#players");
  final InputElement _name = querySelector("#name");
  final _active = new Checkbox(querySelector("#active"));

  PlayerPage(){
    _playerDataChange.stream.listen(PlayerManager.save);

    _players.onChange.listen(_onSelectionChange);
    _name.onChange.listen(_onNameChange);
    _active.onChange.listen(_onActiveChange);
    querySelector("#addNewPlayer").onClick.listen(_onAddNewPlayerClick);

    PlayerManager.loadAll().then(_onPlayersLoad);
  }

  Player get _currentPlayer => PlayerManager.get(int.parse(_players.value));

  _onPlayersLoad(_){
    _players.children.clear();
    var models = PlayerManager.models;
    var opts = models.map((p)=> new PlayerOption(p).element);
    _players.children.addAll(opts);
    _players.value = "${models.first.id}";
    _onSelectionChange();
  }

  _onSelectionChange([_]){
    var p = _currentPlayer;
    _name.value = p.name;
    _active.value = p.active;
  }

  _onNameChange(_){
    _currentPlayer.name = _name.value;
    _playerDataChange.add(_currentPlayer);
  }

  _onActiveChange(_){
    _currentPlayer.active = _active.value;
    _playerDataChange.add(_currentPlayer);
  }

  _onAddNewPlayerClick(_){
    PlayerManager.create(new Player.brandNew()).then((Player p){
      _players.append(new PlayerOption(p).element);
      _players.value = p.id.toString();
      _onSelectionChange();
    });
  }
}

class PlayerOption{
  final OptionElement element = new OptionElement();
  final Player player;

  PlayerOption(this.player){
    element.value = player.id.toString();
    _playerDataChange.stream.where((p)=> p == player).listen(_redraw);
    _redraw(null);
  }

  _redraw(_){
    element.text = player.name;
  }
}
