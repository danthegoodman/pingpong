library us.kirchmeier.pingpong.scorekeeper.gameover;

import 'dart:html';
import 'sc_common.dart';
import 'game_page.dart';
import 'player_page.dart';
import 'key_handler.dart';
import 'package:pingpong/common.dart';

KeyHandler _keyHandler;
Element _playAnotherGame;
Element _winnersHeader;
Element _subHeader;
Element _winTitle;

class GameOverPage extends ManagerPage{
  final Element element = query("#gameover");

  GameOverPage(){
    _playAnotherGame = query("#playAnotherGame");
    _winnersHeader = query("#winners");
    _subHeader = query("#subwinners");
    _winTitle = query("#winTitle");
    _keyHandler = new KeyHandler();

    _playAnotherGame.onClick.listen(_onPlayAnotherGameClick);
    query("#gameOverUndo").onClick.listen(_onUndoScoreAction);
    query("#returnToSetup").onClick.listen(_onReturnToSetupClick);
    _keyHandler.onUndo.listen(_onUndoScoreAction);
  }

  void onShow(){
    _playAnotherGame.style.display = "";
    if(TOURNAMENT != null && GAME.tournamentId == TOURNAMENT.id){
      _renderTournamentText();
    } else {
      _renderRegularText();
    }
    _keyHandler.enable();
  }

  void onHide(){
    _keyHandler.disable();
  }
}

_onUndoScoreAction(q){
  undoLastGamePoint();
  PageManager.goto(GamePage);
}

_onReturnToSetupClick(q){
  _completeGame().then((q){
    GAME = null;
    PageManager.goto(PlayerPage);
  });
}

_onPlayAnotherGameClick(q){
  _completeGame().then(_createNewGame).then((newGame){
    GAME = newGame;
    PageManager.goto(GamePage);
  });
}

Future _completeGame(){
  GAME.inProgress = false;
  GAME.finish = new DateTime.now();

  var futList = [];
  if(TOURNAMENT != null && TOURNAMENT.id == GAME.tournamentId){
    _addGameToTournament();
    futList.add(TournamentManager.save(TOURNAMENT));
  }

  futList.add(GameManager.save(GAME));
  return Future.wait(futList);
}

Future _createNewGame(q){
  var t0 = new List.from(GAME.team[0]);
  var t1 = new List.from(GAME.team[1]);

  int count = GAME.gameInMatch + 1;
  if(count%2 == 0){ //Switch the starting server
    t0 = new List.from(t0.reversed);
    t1 = new List.from(t1.reversed);
  }

  var newGame = new Game.brandNew()
    ..gameInMatch = count
    ..parentId = GAME.id
    ..tournamentId = GAME.tournamentId
    ..teams = [t1, t0]; //Switch sides so other team starts serving

  return GameManager.create(newGame);
}

_addGameToTournament(){
  var teams = GAME.team;
  var winTeam = GAME.winningTeam;
  var loseTeam = (winTeam-1).abs();
  var players = TOURNAMENT.players;
  int win = players.indexOf(teams[winTeam].first);
  int lose = players.indexOf(teams[loseTeam].first);

  TOURNAMENT.table[win][lose].add(GAME.id);
}

_renderRegularText(){
  var scores = GAME.score;

  var winners = GAME.team[GAME.winningTeam].map((p)=> p.name);
  _winnersHeader.text = winners.join(" and ");
  _subHeader.text = "";

  if(winners.length == 1){
    _winTitle.text = '... and the winner is:';
  } else {
    _winTitle.text = '... and the winners are:';
  }
}

_renderTournamentText(){
  int winTeam = GAME.winningTeam;
  int loseTeam = (winTeam-1).abs();

  Player winPlayer = GAME.team[winTeam].first;
  Player losePlayer = GAME.team[loseTeam].first;

  List<int> scores = getTournamentScores();
  scores[winTeam] += 1;

  if(scores[0] == 2 || scores[1] == 2){
    _winTitle.text = '... and the winner of the match is:';
    _winnersHeader.text = winPlayer.name;
    _subHeader.text = '';
    _playAnotherGame.style.display = 'none';
  } else {
    _winTitle.text = '... and the standings are:';
    _winnersHeader.text = '${winPlayer.name} - ${scores[winTeam]}';
    _subHeader.text = '${losePlayer.name} - ${scores[loseTeam]}';
  }
}
