library us.kirchmeier.pingpong.scorekeeper.game;

import 'dart:html';
import 'sc_common.dart';
import 'key_handler.dart';
import 'player_page.dart';
import 'gameover_page.dart';
import 'package:pingpong/common.dart';

Element _page;
KeyHandler _keyHandler;
List<NameCell> _nameCells;
List<ScoreCell> _scoreCells;
TournamentBar _tournamentBar;

class GamePage extends ManagerPage{
  Element element;

  GamePage(){
    _page = element = query("#game");
    _keyHandler = new KeyHandler();

    _nameCells = [
      new NameCell('serve', 0),
      new NameCell('standby', 0),
      new NameCell('serve', 1),
      new NameCell('standby', 1),
    ];
    _scoreCells = [
      new ScoreCell(0),
      new ScoreCell(1),
    ];

    _tournamentBar = new TournamentBar();
    _keyHandler.onUndo.listen((q)=> undoLastGamePoint());
    _keyHandler.onBadServe.listen((q)=> recordBadServe());
    query("#undoScore").onClick.listen((q)=> undoLastGamePoint());
    query("#badServe").onClick.listen((q)=> recordBadServe());
    query("#cancelGame").onClick.listen(_onCancelGameClick);

    onSideFlip.listen(_redrawAll);
    onScoreChange.listen(_onScoreChange);
  }

  void onShow(){
    _keyHandler.enable();
    _redrawAll();
  }

  void onHide(){
    _keyHandler.disable();
  }
}

void _redrawAll([q]){
  _tournamentBar.redraw();
  _onScoreChange();
}

void _onScoreChange([q]){
  if(GAME == null) return;
  int team = currentServingTeam();

  var c = _page.classes;
  (team == 0 ? c.add : c.remove)('leftServing');
  (team == 1 ? c.add : c.remove)('rightServing');

  if(GAME.isComplete){
    PageManager.goto(GameOverPage);
  }

  _nameCells.forEach((NameCell nc)=> nc.redraw());
  _scoreCells.forEach((ScoreCell sc)=> sc.redraw());
}

void _onCancelGameClick(q){
  bool b = window.confirm("Are you sure you want to cancel this game?");
  if(!b) return;

  PageManager.goto(PlayerPage);
  GameManager.delete(GAME).then((q){
    GAME = null;
  });
}

class NameCell{
  Element element;
  int _team;
  int _position;

  NameCell(String type, this._team){
    _position = (type == 'serve' ? 0 : 1);
    element = query("#$type$_team");
    element.onClick.listen(_onClick);
    _keyHandler.onScore.where((PlayerKeyEvent p)=> p.team == _team && p.position == _position).listen(_onClick);
  }

  void redraw(){
    bool visible = (_position < GAME.team[_team].length);
    element.parent.style.display = (visible ? '' : 'none');
    if(!visible) return;

    Player player = playerBasedOnScore(_team, _position);
    element.text = player.name;
  }

  void _onClick(q){
    Player player = playerBasedOnScore(_team, _position);
    addGamePointBy(player);
  }
}

class ScoreCell{
  Element element;
  int team;
  ScoreCell(this.team){
    element = query("#score$team");
  }
  redraw(){
    element.text = GAME.score[team].toString();
  }
}

class TournamentBar{
  Element _bar = query("#tournamentStatus");
  Element _left;
  Element _right;

  TournamentBar(){
    _bar.style.display = "none";
    _left = _bar.query(".left");
    _right = _bar.query(".right");
  }

  redraw(){
    _left.children.clear();
    _right.children.clear();
    List<int> scores = getTournamentScores();
    _bar.style.display = scores.isEmpty ? "none" : "";
    if(scores.isEmpty) return;

    _renderStars(_left, scores[0]);
    _renderStars(_right, scores[1]);
  }

  void _renderStars(Element el, int n){
    for(int i = 0; i < n; i++){
     el.appendHtml("<span class='star'/>");
    }
  }
}
