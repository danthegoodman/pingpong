part of pingpong.scorekeeper;

class GameOverPage extends ManagerPage{
  final Element element = querySelector("#gameover");
  final _winnersHeader = querySelector("#gameover .winners");
  final _winTitle = querySelector("#gameover .winTitle");
  final _keyHandler = new KeyHandler();
  Game _game;

  GameOverPage(){
    _keyHandler.onUndo.listen(_onUndoScoreAction);
    querySelector("#gameover .undo").onClick.listen(_onUndoScoreAction);
    querySelector("#gameover .playAnother").onClick.listen(_onPlayAnotherGameClick);
    querySelector("#gameover .returnToSetup").onClick.listen(_onReturnToSetupClick);
  }

  void onShow(Game game){
    _game = game;
    var winners = _game.team[_game.winningTeam].map((p)=> p.name);
    _winnersHeader.text = winners.join(" and ");

    if(winners.length == 1){
      _winTitle.text = '... and the winner is:';
    } else {
      _winTitle.text = '... and the winners are:';
    }

    _keyHandler.enable();
  }

  void onHide(){
    _game = null;
    _keyHandler.disable();
  }

  _onUndoScoreAction(_){
    _game.points.removeLast();
    soundManager.undo();
    GameManager.save(_game);
    PageManager.goto(GamePage, _game);
  }

  _onReturnToSetupClick(_){
    _completeGame().then((_)=> PageManager.goto(PlayerPage));
  }

  _onPlayAnotherGameClick(_){
    _completeGame().then(_createNewGame).then((newGame)=> PageManager.goto(GamePage, newGame));
  }

  Future _completeGame(){
    _game.finish = new DateTime.now();
    return postJSON('/api/completeGame', _game);
  }

  Future _createNewGame(_){
    var players = _game.players;
    players.add(players.removeAt(0));

    var newGame = new Game()
      ..gameInMatch = _game.gameInMatch + 1
      ..parentId = _game.id
      ..players = players;

    return GameManager.create(newGame);
  }
}
