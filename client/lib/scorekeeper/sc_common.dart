library us.kirchmeier.pingpong.scorekeeper.common;

import 'package:pingpong/common.dart';
import 'dart:math';

Random RNG = new Random(new DateTime.now().millisecondsSinceEpoch);
Game GAME;
Tournament TOURNAMENT;

StreamController<ScoreChange> _scoreChange = new StreamController<ScoreChange>.broadcast();
StreamController<ScoreChange> _sideFlip = new StreamController<ScoreChange>.broadcast();
final Stream<ScoreChange> onScoreChange = _scoreChange.stream;
final Stream<ScoreChange> onSideFlip = _sideFlip.stream;

void undoLastGamePoint(){
  List<int> hist = GAME.scoreHistory;
  if(hist.isEmpty){
    switchTeamSides();
    return;
  }

  int lastTeam = hist.removeLast();
  String lastPointId = GAME.points[lastTeam].removeLast();

  PointManager.delete(new Point()..id=lastPointId);
  GameManager.save(GAME);
  _scoreChange.add(const ScoreChange._undo());
}

void recordBadServe(){
  Point newPoint = _createPoint()..badServe = true;

  PointManager.create(newPoint).then((realPoint){
    var otherTeam = (currentServingTeam()-1).abs();
    GAME.points[otherTeam].add(realPoint.id);
    GAME.scoreHistory.add(otherTeam);
    GameManager.save(GAME);
    _scoreChange.add(const ScoreChange._badServe());
  });
}

void addGamePointBy(Player p){
  Point newPoint = _createPoint()..scoringPlayer = p.id;

  PointManager.create(newPoint).then((realPoint){
    int scoreTeam = GAME.team[0].contains(p) ? 0 : 1;
    GAME.points[scoreTeam].add(realPoint.id);
    GAME.scoreHistory.add(scoreTeam);
    GameManager.save(GAME);
    _scoreChange.add(const ScoreChange._point());
  });
}

void switchTeamSides(){
  var teams = GAME.team;
  var newTeams = new List(2);
  //Reversing keeps player ordering the same.
  newTeams[0] = teams[1].reversed;
  newTeams[1] = teams[0];
  GAME.teams = newTeams;
  GameManager.save(GAME);
  _sideFlip.add(null);
}

int currentServingTeam(){
  int score = GAME.totalScore;
  if(score < 40){
    return ((score % 10) < 5) ? 0 : 1;
  } else {
    return score % 2;
  }
}

Player playerBasedOnScore(int teamN, int position){
  List<Player> team = GAME.team[teamN];
  if(team.length == 1) return team.first;

  int score = GAME.totalScore;
  bool flipPosition = false;
  if(score < 40){
    if(teamN == 0) score += 5;
    if( score % 20 >= 10) flipPosition = true;
  } else {
    if(teamN == 0) score += 1;
    if( score % 4 >= 2) flipPosition = true;
  }

  if(flipPosition) position = (position-1).abs();
  return team[position];
}

List<int> getTournamentScores(){
  if(TOURNAMENT == null) return [];
  var teams = GAME.team;
  if(teams[0].length == 2) return [];

  var players = TOURNAMENT.players;
  int a = players.indexOf(teams[0].first);
  int b = players.indexOf(teams[1].first);
  if(a == -1 || b == -1) return [];

  List<int> result = new List<int>(2);
  result[0] = TOURNAMENT.table[a][b].length;
  result[1] = TOURNAMENT.table[b][a].length;
  return result;
}

Point _createPoint(){
  int servingTeam = currentServingTeam();
  int receivingTeam = (servingTeam-1).abs();

  Point p = new Point()
    ..game = GAME.id
    ..server = playerBasedOnScore(servingTeam, 0).id
    ..receiver = playerBasedOnScore(receivingTeam, 0).id;

  if(GAME.team[0].length == 2){
    p.serverPartner = playerBasedOnScore(servingTeam, 1).id;
    p.receiverPartner = playerBasedOnScore(receivingTeam, 1).id;
  }

  return p;
}

class ScoreChange{
  final bool isUndo;
  final bool isPoint;
  final bool isBadServe;

  const ScoreChange._undo():
    isUndo = true,
    isPoint = false,
    isBadServe = false;

  const ScoreChange._point():
    isUndo = false,
    isPoint = true,
    isBadServe = false;

  const ScoreChange._badServe():
    isUndo = false,
    isPoint = false,
    isBadServe = true;

  int get delta => isUndo ? -1 : 1;
}
