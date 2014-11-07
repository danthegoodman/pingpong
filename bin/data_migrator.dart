library pingpong.data_migrator;

import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';

final Db oldDb = new Db('mongodb://localhost/pingpong');
final Db newDb = new Db('mongodb://localhost/pingpong2');
final allPoints = new Map<ObjectId, Map>();

void main(){
  Future.wait([oldDb.open(), newDb.open()])
    .then((_) => newDb.drop())
    .then(_copyPlayers)
    .then(_loadPoints)
    .then(_copyGames)
    .whenComplete((){
      oldDb.close();
      newDb.close();
    });
}

_copyPlayers(_){
  int count = 0;
  return oldDb.collection('players').find().toList()
    .then((players){
      var l = players.map(_transformPlayer).toList();
      count = l.length;
      return newDb.collection('players').insertAll(l);
    }).then((_) => print("Copied ${count} players"));
}

_transformPlayer(Map m) => {
    '_id': m['_id'],
    'name': m['name'],
    'active': m['active'] == true,
    'guest': m['name'].contains('Guest'),
    'frequent': false,
};

_loadPoints(_) {
  return oldDb.collection('points').find().stream.listen((pt) {
    allPoints[pt['_id']] = pt;
  }).asFuture()
    .then((_)=> print("Loaded ${allPoints.length} points"));
}

_copyGames(_){
  int gameIndex = 0;
  var warnings = [];
  var newGames = [];
  final gameCountsInMatch = new Map<ObjectId, int>();

  return oldDb.collection('games').find().stream.listen((Map oldGame){
    if (gameIndex % 100 == 0) print("  Converting game ${gameIndex}");
    gameIndex++;

    var gameInMatch = oldGame['gameCount'];
    if (gameInMatch == null && oldGame['parent'] != null) gameCountsInMatch[oldGame['parent']];
    if (gameInMatch == null) gameInMatch = 0;
    gameCountsInMatch[oldGame['_id']] = gameInMatch + 1;

    var players = _buildPlayerList(oldGame);
    var points = _buildPointList(warnings, oldGame, players);

    if (points.isEmpty) {
      return;
    }
    var oldScore = "${oldGame['score0'].length}/${oldGame['score1'].length}";
    var newScore = "${points.where((x)=> x.abs() == 1).length}/${points.where((x)=> x.abs() == 2).length}";
    if(oldScore != newScore){
      warnings.add("Unequal score : ${oldScore} :: ${newScore}");
    }

    newGames.add({
        '_id': oldGame['_id'],
        'gameInMatch': gameInMatch,
        'parentId': oldGame['parent'],
        'players': players,
        'points': points,
        'date': oldGame['date'],
        'finish': oldGame['finish'],
    });
  }).asFuture()
    .then((_) => newDb.collection('games').insertAll(newGames))
    .then((_) {
      print("Copied ${gameIndex} Games\n");
      warnings.forEach(print);
    });
}

List _buildPlayerList(Map oldGame) {
  var team0 = oldGame['team0']..add(null);
  var team1 = oldGame['team1']..add(null);
  var l = [team0[0], team1[0], team0[1], team1[1]];
  l.removeWhere((x) => x == null);
  return l;
}

_buildPointList(List warnings, Map g, List players) {
  var s0 = new List.from(g['score0']);
  var s1 = new List.from(g['score1']);
  var hist = new List.from(g['scoreHistory']);
  var valid = _scrubScores(warnings, s0, s1, hist, g['_id'].toHexString());
  if (!valid) return [];

  List<List> oldScores = [s0.reversed.toList(), s1.reversed.toList()];

  return hist
    .map((t) => allPoints[oldScores[t].removeLast()])
    .map((pt) => _transformPoint(pt, players))
    .toList();
}

_transformPoint(Map pt, List players){
  var badServe = pt['badServe'] == true;
  var player = badServe ? pt['receiver'] : pt['scoringPlayer'];
  var ndx = players.indexOf(player);
  if(ndx == -1) throw "Player not found in players :: ${player} - ${players}";
  return (ndx % 2 + 1) * (badServe ? -1 : 1);
}

_scrubScores(List warnings, List s0, List s1, List hist, id) {
  if(s0.length == 0 && s1.length == 0){
    return false; //ignore the dup bug.
  }

  if (s0.length < 21 && s1.length < 21) {
    warnings.add("Game is not complete (${s0.length} - ${s1.length}) - $id");
    return false;
  }

  rem0() {
    s0.removeLast();
    hist.removeLast();
    warnings.add("Removed extra point from team 0 - $id");
  }

  rem1() {
    s1.removeLast();
    hist.removeLast();
    warnings.add("Removed extra point from team 1 - $id");
  }

  while (s0.length > 21 && s1.length < 20) {
    rem0();
  }

  while (s1.length > 21 && s0.length < 20) {
    rem1();
  }

  while (s0.length >= 20 && s1.length >= 20 && (s0.length - s1.length).abs() > 2) {
    (s0.length > s1.length) ? rem0() : rem1();
  }
  return true;
}
