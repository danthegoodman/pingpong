library us.kirchmeier.pingpong.reports.tournament;

import 'dart:html';
import 'dart:collection';
import "package:pingpong/common.dart";

class TournamentReport extends ManagerPage{
  final Element element = query("#tournament");
  final TableElement _standings = query("#tournament .standings table");
  final TableElement _details = query("#tournament .details table");

  final StreamController<Player> _playerSelection = new StreamController.broadcast();
  Tournament tournament;

  TournamentReport(){
    _playerSelection.stream.listen(_onPlayerSelect);
  }

  set currentTournament(Tournament t){
    tournament = t;

    Map<Player,int> m = _getStandings(t);
    m.forEach((Player p, int n){
      _standings.append(_createStandingsRow(p, n));
    });
    _playerSelection.add(m.keys.first);
  }

  _onPlayerSelect(Player p){
    _details.children.clear();
    _getDetails(tournament, p).then(_renderDetails);
  }

  _renderDetails(Map<Player, List<MatchDetail>> details){
    details.forEach((Player p, List<MatchDetail> list){
      var matches = list.map((MatchDetail m){
        return "<div class='game ${m.winner ? 'win' : 'lose'}'>${m.myScore} - ${m.theirScore}</div>";
      });
      var tr = new TableRowElement();
      tr.appendHtml("<td>vs ${p.name}</td><td>${matches.join('')}</td>");
      _details.append(tr);
    });
  }

  void onShow(){
  }

  Element _createStandingsRow(Player p, int wins){
    String w;
    if(wins == -1) w = '';
    else w = (wins == 1 ? "1 win" : "$wins wins");

    var el = new TableRowElement();
    el.appendHtml("""
      <td>${p.name}</td>
      <td>$w</td>
      """);

    el.onClick.listen((q){
      _playerSelection.add(p);
    });

    _playerSelection.stream.listen((Player sel){
      if(sel.id == p.id) el.classes.add('selected');
      else el.classes.remove('selected');
    });

    return el;
  }


}

Map<Player, int> _getStandings(Tournament t){
  var players = t.players;
  var data = t.table;
  if(data == null) return {};

  var joined = [];
  for(int a = 0; a < players.length; a++){
    var results = [];
    for(int b = 0; b < players.length; b++){
      if(a == b) continue;
      bool r = _doesPlayerWinMatch(data, a, b);
      if(r != null) results.add(r);
    }
    joined.add([players[a], _countMatchWins(results)]);
  }

  return _formatStandings(joined);
}

bool _doesPlayerWinMatch(data, int a, int b){
  int win = data[a][b].length;
  int lose = data[b][a].length;
  if(win == 2) return true;
  if(lose == 2) return false;
  return null;
}

int _countMatchWins(List<bool> results){
  if(results.isEmpty) return -1;
  return results.where((x)=> x == true).length;
}

Map<Player, int> _formatStandings(List joinedList){
  joinedList.sort((a,b){
    int winCmp = Comparable.compare(a[1], b[1]);
    return winCmp != 0 ? winCmp : Comparable.compare(b[0], a[0]);
  });
  var result = new LinkedHashMap<Player, int>();
  joinedList.reversed.forEach((x)=> result[x[0]] = x[1]);
  return result;
}

Future<Map<Player, List<MatchDetail>>> _getDetails(Tournament t, Player p){
  Completer c = new Completer();
  List<Player> players = t.players;
  var pNdx = players.indexOf(p);
  _fetchAllMatchGames(t, pNdx).then((q){
    var results = [];
    for(int i = 0; i < players.length; i++){
      if(i == pNdx) continue;
      var opponent = players[i];
      results.add([opponent, _collectMatchGames(t, p, pNdx, i)]);
    }

    var res = new LinkedHashMap<Player, List<MatchDetail>>();
    results
      ..sort((a,b)=> Comparable.compare(a[0], b[0]))
      ..forEach((x)=> res[x[0]] = x[1]);
    c.complete(res);
  });
  return c.future;
}

Future<List<Game>> _fetchAllMatchGames(Tournament t, int playerNdx){
  Completer c = new Completer();
  var data = t.table;

  var games = [];
  for(var i = 0; i < t.players.length; i++){
    if(i == playerNdx) continue;
    games.addAll(data[playerNdx][i]);
    games.addAll(data[i][playerNdx]);
  }

  var futList = [];
  for(String g in games){
    futList.add(GameManager.fetch(g));
  }
  Future.wait(futList).then(c.complete);
  return c.future;
}

List<MatchDetail> _collectMatchGames(Tournament t, Player p, int pNdx, int oNdx){
  var d = t.table;
  var games = GameManager.mapFrom([]..addAll(d[pNdx][oNdx])..addAll(d[oNdx][pNdx]));
  games.sort();
  return new List.from(games.map((Game g)=> new MatchDetail(p, g)));
}

class MatchDetail{
  bool winner;
  int myScore;
  int theirScore;

  MatchDetail(Player p, Game g){
    int team = g.team[0].contains(p) ? 0 : 1;
    myScore = g.score[team];
    theirScore = g.score[(team-1).abs()];
    winner = myScore > theirScore;
  }
}
