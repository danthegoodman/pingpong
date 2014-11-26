part of pingpong.scorekeeper;

class GameOverPage extends ManagerPage {
  final _keyHandler = new KeyHandler();
  final Game _game;

  GameOverPage(this._game) {
    element.id = "gameover";
    _buildLayout();

    _keyHandler.onUndo.listen(_onUndoScoreAction);
  }

  @override
  void onLeave() {
    _keyHandler.close();
  }

  _buildLayout(){
    var winners = _game.team[_game.winningTeam].map((p) => p.name);
    var winTitle = winners.length == 1 ? '... and the winner is:' : '... and the winners are:';

    var header = (txt, style)=> new DivElement()..text=txt..className=style;
    var headerSection = new DivElement()
      ..className = "headerSection"
      ..append(header(winTitle, 'winTitle'))
      ..append(header(winners.join(' and '), 'winners'));

    var button = (txt, handler, style)=> new DivElement()..text=txt..className=style..onClick.first.then(handler);
    var buttonSection = new DivElement()
      ..className = "buttonSection"
      ..append(button("Undo Last Score", _onUndoScoreAction, 'undo'))
      ..append(button("Play Another Game", _onPlayAnotherGameClick,"playAnother"))
      ..append(button("Return to Player Selection", _onReturnToSetupClick, 'returnToSetup'));

    element..append(headerSection)..append(buttonSection);
  }

  _onUndoScoreAction(_) {
    _game.undoLastPoint();
    soundManager.undo();
    GameManager.save(_game);
    PageManager.goto(new GamePage(_game));
  }

  _onReturnToSetupClick(_) {
    _completeGame().then((_) => PageManager.goto(new PlayerPage()));
  }

  _onPlayAnotherGameClick(_) {
    _completeGame().then(_createNewGame).then((newGame) => PageManager.goto(new GamePage(newGame)));
  }

  Future _completeGame() {
    _game.finish = new DateTime.now();
    return postJSON('/api/completeGame', _game);
  }

  Future _createNewGame(_) {
    var newGame = new Game.afterGame(_game);
    return GameManager.create(newGame);
  }
}
