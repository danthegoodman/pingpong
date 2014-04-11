part of pingpong.scorekeeper;


class TeamPage extends ManagerPage{
  final Element element = querySelector("#teamPage");
  final TableSectionElement _teamContainer = querySelector("#teamPage .container");
  final _cancelButton = querySelector("#teamPage .cancel");
  List<String> _searchedPlayers;

  TeamPage(){
    _cancelButton.onClick.listen((q)=> PageManager.goto(PlayerPage));
  }

  void onShow(Iterable<Player> players){
    _searchedPlayers = players.map((p)=> p.id).toList()..sort();
    postJSON('/report/matchProbability', {'players': _searchedPlayers}).then(_onPlayersGamesResult);
  }

  void _onPlayersGamesResult(Iterable data){
    _teamContainer.children.clear();
    List<_TeamGroup> groups = _processData(data);
    groups.sort();

    var mostSignificant = _findMostSignificant(groups);
    for(var g in groups){
      _renderGroup(g, mostSignificant);
    }
  }

  List<_TeamGroup> _processData(Iterable data){
    var result = new Map<String, Map<String, _Team>>();
    data.forEach((d){
      var players = d['players'];
      var group = "${players[0]}-${players[2]}";
      result.putIfAbsent(group, ()=> new Map<String, _Team>())
            .putIfAbsent(players.join(','), ()=> new _Team(PlayerManager.mapFrom(players)))
               ..team0 += d['team0']
               ..team1 += d['team1'];
    });

    return result.values.map((v)=>new _TeamGroup(v.values)).toList();
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
    if(t.team0 == t.team1) return "No favor";
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

    var newGame = new Game()..players = p;

    GameManager.create(newGame).then((realGame){
      PageManager.goto(GamePage, realGame);
    });
  }
}

class _TeamGroup extends _HasCounts{
  List<_Team> teams;

  _TeamGroup(Iterable<_Team> t){
    teams = t.toList()..sort();
    for(var t in teams){
      team0 += t.team0;
      team1 += t.team1;
    }
  }

  List get players => teams[RNG.nextInt(2)].players;

  String get favoredSide => team0 > team1 ? teams.first.startSide : teams.first.otherSide;

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

  String get favoredSide => team0 > team1 ? startSide : otherSide;

  String toString()=> players.join(' > ');
}

class _HasCounts implements Comparable<_HasCounts>{
  int team0 = 0;
  int team1 = 0;

  int get games => team0+team1;
  bool get isSignificant => games >= 10;
  num get ratio => games == 0 ? 1 : ((team0-team1)/games).abs();

  num get favoredPercentage {
    num r = games == 0 ? 1 : math.max(team0, team1)/games;
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
