part of pingpong.scorekeeper;

class PlayerPage extends ManagerPage{
  final _playersContainer = new DivElement()..id = 'players';
  final _beginButton = new DivElement()..className='begin'..text="Begin";

  final _selection = new Set<Player>();
  final _playerSelectionChange = new StreamController<Player>.broadcast();

  PlayerPage(){
    element
      ..id = "playerPage"
      ..append(_playersContainer)
      ..append(new DivElement()..className='buttonSection'..append(_beginButton))
      ..append(new AnchorElement()..href='config.html'..id='configure'..className='icon-cog');

    var players = PlayerManager.models.where((x)=> x.active);
    _playersContainer.children
      ..addAll(players.where((x)=> !x.guest).map(_createPlayerButton))
      ..addAll(players.where((x)=>  x.guest).map(_createPlayerButton));

    _beginButton.onClick.first.then(_onBeginClick);
    _playerSelectionChange.stream.listen(_onPlayerSelectionChange);

    _beginButton.style.opacity = "0";
  }

  void _onBeginClick(e){
    if(_selection.length != 4 && _selection.length != 2) return;

    var players = _selection.toList();
    if(_selection.length == 4){
      PageManager.goto(new TeamPage(players));
      return;
    }

    //Shuffle the sides.
    if(RNG.nextBool()) players = players.reversed.toList();

    GameManager.create(new Game(players)).then((realGame){
      PageManager.goto(new GamePage(realGame));
    });
  }

  void _onPlayerSelectionChange(q){
    bool canBegin = _selection.length == 2 || _selection.length == 4;
    _beginButton.style.opacity = (canBegin ? "1" : "0");
  }

  Element _createPlayerButton(Player p){
    var el = new DivElement()..text = p.name;

    el.onClick.listen((_){
      _togglePlayerSelection(p);
      el.classes.toggle('selected', _selection.contains(p));
    });
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

