part of pingpong.scorekeeper;

class PlayerPage extends ManagerPage{
  final Element element = querySelector("#playerPage");
  final _playersContainer  = querySelector("#playerPage #players");
  final _beginButton = querySelector("#playerPage .begin");
  final _selection = new Set<Player>();
  final _playerSelectionChange = new StreamController<Player>.broadcast();

  PlayerPage(){
    PlayerManager.onLoadAll.listen(_onLoadAll);
    _beginButton.onClick.listen(_onBeginClick);
    _playerSelectionChange.stream.listen(_onPlayerSelectionChange);
  }

  void onShow(data){
    _beginButton.style.opacity = "0";
    _selection.toList().forEach(_togglePlayerSelection);
  }

  void _onBeginClick(e){
    if(_selection.length != 4 && _selection.length != 2) return;

    var players = _selection.toList();

    if(_selection.length == 4){
      PageManager.goto(TeamPage, players);
      return;
    }

    //Shuffle the sides.
    if(RNG.nextBool()) players = players.reversed.toList();

    var newGame = new Game()..players = players;
    GameManager.create(newGame).then((realGame){
      PageManager.goto(GamePage, realGame);
    });
  }

  void _onPlayerSelectionChange(q){
    bool canBegin = _selection.length == 2 || _selection.length == 4;
    _beginButton.style.opacity = (canBegin ? "1" : "0");
  }

  void _onLoadAll(q){
    _playersContainer.children = PlayerManager.models.map(_createPlayerButton);
  }

  Element _createPlayerButton(Player p){
    var el = new DivElement();
    el.hidden = !p.active;
    el.text = p.name;

    _playerSelectionChange.stream.where((p2)=> p == p2).listen((_){
      el.classes.toggle('selected', _selection.contains(p));
    });

    el.onClick.listen((_)=> _togglePlayerSelection(p));
    return el;
  }

  void _togglePlayerSelection(Player p){
    if(_selection.contains(p)){
      _selection.remove(p);
    } else {
      _selection.add(p);
    }
    _playerSelectionChange.add(p);
  }
}

