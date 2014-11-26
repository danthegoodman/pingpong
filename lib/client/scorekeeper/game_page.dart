part of pingpong.scorekeeper;

class GamePage extends ManagerPage {
  final _keyHandler = new KeyHandler();
  final _nameCells = new List<Element>();
  final _scoreCells = new List<Element>();
  final _message = new DivElement()..className = 'message';
  final Game _game;

  GamePage(this._game) {
    element.id = "game";
    _buildLayout();

    _keyHandler
      ..onUndo.listen(_onUndoClick)
      ..onBadServe.listen(_onBadServeClick)
      ..onScore.listen((e) => _addGamePointBy(e.team));
    _redraw();
  }

  void _buildLayout(){
    var cancel = new DivElement()..text="Cancel Game"..className="cancel"..onClick.first.then(_onCancelGameClick);
    var badServe = new DivElement()..text="Bad Serve"..className="button"..onClick.listen(_onBadServeClick);
    var undo = new DivElement()..text="Undo Last Score"..className="button"..onClick.listen(_onUndoClick);
    var teamContainer0 = new DivElement()..className="teamContainer";
    var teamContainer1 = new DivElement()..className="teamContainer";

    var playerCount = _game.players.length;
    for (var i = 0; i < playerCount; i++) {
      var team = i.isEven ? T0 : T1;
      var e = new DivElement()..onClick.listen((_) => _addGamePointBy(team));
      if(team == T0){
        teamContainer0.children.insert(0, e);
      } else {
        teamContainer1.append(e);
      }
      _nameCells.add(e);
    }

    _scoreCells
      ..add(new DivElement()..className="score left"..onClick.listen((_)=> _addGamePointBy(T0)))
      ..add(new DivElement()..className="score right"..onClick.listen((_)=> _addGamePointBy(T1)));

    var scoreContainer = new DivElement()
      ..className = 'infoContainer'
      ..append(_message)
      ..append(new DivElement()..className = 'scoreContainer'..append(_scoreCells[0])..append(_scoreCells[1]))
      ..append(new DivElement()..className = 'buttonContainer'..append(undo)..append(badServe));

    element
      ..append(cancel)
      ..append(teamContainer0)
      ..append(scoreContainer)
      ..append(teamContainer1);
  }

  @override
  void onLeave() {
    _keyHandler.close();
  }

  void _onUndoClick(_) {
    if (_game.totalScore == 0) {
      _game.switchSides();
    } else {
      _game.undoLastPoint();
    }
    soundManager.undo();
    GameManager.save(_game);
    _redraw();
  }

  void _onBadServeClick(_) {
    if (!_game.addBadServe()) return;

    if (_game.isComplete) {
      soundManager.sadTrombone();
    } else {
      soundManager.badServe();
    }

    GameManager.save(_game);
    _redraw();
  }

  void _addGamePointBy(Team t) {
    if (!_game.addPointByTeam(t)) return;

    soundManager.score();
    GameManager.save(_game);
    _redraw();
  }

  void _onCancelGameClick(_) {
    bool b = window.confirm("Are you sure you want to cancel this game?");
    if (!b) return;

    GameManager.delete(_game);
    PageManager.goto(new PlayerPage());
  }

  void _redraw() {
    var team = _game.currentServingTeam;
    element.classes
      ..toggle('leftServing', team == T0)
      ..toggle('rightServing', team == T1);

    _redrawNames();
    _redrawScores();
    _redrawMessage();

    if (_game.isComplete) {
      PageManager.goto(new GameOverPage(_game));
    }
  }

  void _redrawNames() {
    var players = _game.shiftedPlayers;
    for (var i = 0; i < players.length; i++) {
      _nameCells[i].text = players[i].name;
    }
  }

  void _redrawScores() {
    var s = _game.score;
    _scoreCells[0].text = s[T0].toString();
    _scoreCells[1].text = s[T1].toString();
  }

  void _redrawMessage(){
    var p = _game.lastPoint;
    if(p == null){
      _message.text = "";
    } else if(p.badServe){
      _message.text = "Bad Serve";
    } else {
      _message.text = "Point by ${_game.team[p.team].join(' & ')}";
    }
  }
}
