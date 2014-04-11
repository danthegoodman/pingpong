part of pingpong.scorekeeper;

class GamePage extends ManagerPage{
  final Element element = querySelector("#game");
  final _keyHandler = new KeyHandler();

  List<Element> _nameCells;
  List<Element> _scoreCells;
  Game _game;

  GamePage(){
    _nameCells = new List.generate(4, _createNameCell, growable: false);
    _scoreCells = new List.generate(2, _createScoreCell, growable: false);

    _keyHandler.onUndo.listen(_onUndoClick);
    _keyHandler.onBadServe.listen(_onBadServeClick);
    _keyHandler.onScore.listen((e)=> _addGamePointBy(e.index));

    querySelector("#game .undo").onClick.listen(_onUndoClick);
    querySelector("#game .badServe").onClick.listen(_onBadServeClick);
    querySelector("#game .cancel").onClick.listen(_onCancelGameClick);
  }

  Element _createNameCell(int offset){
    var e = querySelector("#game .player${offset}");
    e.onClick.listen((_)=> _addGamePointBy(offset));
    return e;
  }

  Element _createScoreCell(int team) => querySelector("#game .score${team}");

  void _onUndoClick(_){
    if(_game == null) return;
    if(_game.points.isEmpty){
      var players = _game.players;
      players.add(players.removeAt(0));
      _game.players = players;
    } else {
      _game.points.removeLast();
    }
    soundManager.undo();
    GameManager.save(_game);
    _redraw();
  }

  void _onBadServeClick(_){
    if(_game == null || _game.isComplete) return;
    _game.addBadServe();

    if(_game.isComplete){
      soundManager.sadTrombone();
    } else {
      soundManager.badServe();
    }

    GameManager.save(_game);
    _redraw();
  }

  void _addGamePointBy(int index){
    if(_game == null || _game.isComplete) return;
    index = index % _game.players.length;
    var player = _shiftedPlayerList[index];
    _game.addPointBy(player);
    soundManager.score();
    GameManager.save(_game);
    _redraw();
  }

  void onShow(Game game){
    _game = game;
    _keyHandler.enable();
    _redraw();
  }

  void onHide(){
    _game = null;
    _keyHandler.disable();
  }

  void _onCancelGameClick(_){
    bool b = window.confirm("Are you sure you want to cancel this game?");
    if(!b) return;

    GameManager.delete(_game);
    PageManager.goto(PlayerPage);
  }

  void _redraw(){
    if(_game == null) return;

    var team = _game.currentServingTeam;
    element.classes
      ..toggle('leftServing', team == T0)
      ..toggle('rightServing', team == T1);

    _redrawNames();
    _redrawScores();

    if(_game.isComplete){
      PageManager.goto(GameOverPage, _game);
    }
  }

  void _redrawNames(){
    var players = _shiftedPlayerList;
    for(var i = 0; i < 4; i++){
      var e = _nameCells[i];
      e.parent.hidden = i >= players.length;
      if(!e.parent. hidden){
        e.text = players[i].name;
      }
    }
  }

  void _redrawScores(){
    var s = _game.score;
    _scoreCells[0].text = s[T0].toString();
    _scoreCells[1].text = s[T1].toString();
  }

  List<Player> get _shiftedPlayerList {
    var players = _game.players;
    if(players.length == 2) return players;
    int svr = _game.currentServerIndex;
    var result = players.toList();
    if(svr == 1 || svr == 2){
      result[0] = players[2];
      result[2] = players[0];
    }
    if(svr == 2 || svr == 3){
      result[1] = players[3];
      result[3] = players[1];
    }
    return result;
  }
}
