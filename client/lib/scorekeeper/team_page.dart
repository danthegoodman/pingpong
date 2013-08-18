library us.kirchmeier.pingpong.scorekeeper.team;

import 'dart:html';
import 'dart:math';
import 'sc_common.dart';
import 'game_page.dart';
import 'player_page.dart';
import 'package:pingpong/common.dart';

TableSectionElement _teamContainer;
Element _cancelButton;
List<String> _searchedPlayers;

class TeamPage extends ManagerPage{
  final Element element = query("#teamPage");

  static set playerSelection(Iterable<Player> players){
    _searchedPlayers = (players.toList()..sort()).map((p)=> p.id).toList();
    var data = {'players': _searchedPlayers};
    postJSON('/reports/playersGames', data).then(_onPlayersGamesResult);
  }

  TeamPage(){
    _teamContainer = query("#teamContainer");
    _cancelButton = query("#teamCancel");

    _cancelButton.onClick.listen((q)=> PageManager.goto(PlayerPage));
  }
}

void _onPlayersGamesResult(Iterable data){
  _teamContainer.children.clear();
  Map<String, Map<String, _Team>> results = _processReport(data);
  List<_TeamGroup> groups = results.values.map((v)=>new _TeamGroup(v.values)).toList();
  groups.sort();

  var mostSignificant = _findMostSignificant(groups);
  for(var g in groups){
    _renderGroup(g, mostSignificant);
  }
}

Map<String, Map<String, _Team>> _processReport(Iterable data){
  ///Pivot is arbitrary, but should be consistent across one data set.
  String pivotKey = _searchedPlayers.first;

  var result = new Map<String, Map<String, _Team>>();
  data.forEach((d){
    var val = d['value'];
    var players = d['_id'].split(',');
    if(pivotKey == null) pivotKey = players.first;

    int pivotNdx = players.indexOf(pivotKey);
    if(pivotNdx > 0){
      players.addAll(players.getRange(0, pivotNdx));
      players.removeRange(0, pivotNdx);
    }
    if(pivotNdx%2 == 1){
      int t = val['win'];
      val['win'] = val['lose'];
      val['lose'] = t;
    }

    var group = "${players[0]}-${players[2]}";
    result.putIfAbsent(group, ()=> new Map<String, _Team>())
          .putIfAbsent(players.join(','), ()=> new _Team(PlayerManager.mapFrom(players)))
          .include(val);
  });

  ///Include missing groups
  var sp = _searchedPlayers;
  var permutations = [
    [sp[0], sp[1], sp[2], sp[3]],
    [sp[0], sp[1], sp[3], sp[2]],
    [sp[0], sp[2], sp[1], sp[3]],
    [sp[0], sp[2], sp[3], sp[1]],
    [sp[0], sp[3], sp[1], sp[2]],
    [sp[0], sp[3], sp[2], sp[1]],
  ];
  permutations.forEach((players){
    var group = "${players[0]}-${players[2]}";
    result.putIfAbsent(group, ()=> new Map<String, _Team>())
          .putIfAbsent(players.join(','), ()=> new _Team(PlayerManager.mapFrom(players)));
  });

  return result;
}

_HasCounts _findMostSignificant(List<_TeamGroup> groups){
  List<_HasCounts> countables = new List<_HasCounts>();
  for(var g in groups){
    countables..add(g)..addAll(g.teams);
  }
  countables.sort();
  return countables.first;
}

void _renderGroup(_TeamGroup group, _HasCounts mostSignificant){
  bool sig = group.isSignificant;
  var row = _teamContainer.addRow();
  _addCell(row, group, sig: sig, mostSig: group == mostSignificant);

  row = _teamContainer.addRow();
  for(var t in group.teams){
    _addCell(row, t, sig: sig, mostSig: t == mostSignificant);
  }
}

void _addCell(TableRowElement row, _HasCounts t, {bool mostSig, bool sig}){
  var cell = row.addCell();
  if(t is _TeamGroup){
    cell.classes.add('main');
    cell.colSpan = 2;
  } else {
    cell.classes.add('ordered');
  }
  if(sig) cell.classes.add('significant');
  if(mostSig) cell.classes.add('mostSignificant');
  cell.innerHtml = """
    <h1>${t}</h1>
    <p>${t.games} games : ${_favoredSide(t)}</p>
  """;
  cell.onClick.listen((q)=> _createGame(t));
}

_favoredSide(t){
  if(t.win == t.lose) return "No favor";
  String side = t.favoredSide;
  num pct = t.favoredPercentage;
  if(pct.isInfinite){
    return "$side favored at 100%";
  } else {
    return "$side favored at ${pct.toStringAsFixed(1)}%";
  }
}

_createGame(t){
  List<Player> p = t.players.toList();
  int pivot = RNG.nextInt(4);
  if(pivot > 0){
    p.addAll(p.getRange(0, pivot));
    p.removeRange(0, pivot);
  }

  var newGame = new Game.brandNew();
  newGame.teams = [[p[0], p[2]],[p[1],p[3]]];

  GameManager.create(newGame).then((realGame){
    GAME = realGame;
    PageManager.goto(GamePage);
  });
}

class _TeamGroup extends _HasCounts{
  List<_Team> teams;

  _TeamGroup(Iterable<_Team> t){
    teams = t.toList();
    if(teams.length == 1){
      var p = t.first.players;
      teams.add(new _Team([p[0], p[3], p[2], p[1]]));
    }
    print("$teams");
    teams.sort();
    print("$teams");
    for(var t in teams){
      win += t.win;
      lose += t.lose;
    }
  }

  List get players => teams[RNG.nextInt(2)].players;

  String get favoredSide => win > lose ? teams.first.startSide : teams.first.otherSide;

  String toString(){
    var p = teams.first.players;
    var a = [p[0], p[2]]..sort();
    var b = [p[1], p[3]]..sort();
    var x = [a.join(' & '), b.join(' & ')]..sort();
    return x.join(' vs ');
  }
}

class _Team extends _HasCounts{
  final List<Player> players;

  _Team(this.players);

  String get startSide => ([players[0], players[2]]..sort()).join(' & ');
  String get otherSide => ([players[1], players[3]]..sort()).join(' & ');

  String get favoredSide => win > lose ? startSide : otherSide;

  String toString()=> players.join(' > ');

  void include(Map<String, int> counts){
    win += counts['win'];
    lose += counts['lose'];
  }
}

class _HasCounts implements Comparable<_HasCounts>{
  int win = 0;
  int lose = 0;

  int get games => win+lose;
  bool get isSignificant => games >= 10;
  num get ratio => games == 0 ? 1 : ((win-lose)/(win+lose)).abs();

  num get favoredPercentage {
    num r = games == 0 ? 1 : max(win,lose)/games;
    return r*100;
  }

  //Significant teams then lowest ratio then most games
  int compareTo(_HasCounts o) {
    var sig = isSignificant ? 1 : 0;
    var osig = o.isSignificant ? 1 : 0;

    var r = Comparable.compare(osig, sig);
    if(r != 0) return r;

    r = Comparable.compare(ratio, o.ratio);
    if(r != 0) return r;

    return Comparable.compare(o.games, games);
  }
}
