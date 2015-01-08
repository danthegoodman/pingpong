part of pingpong.common;

ModelManager<Game> GameManager = new ModelManager<Game>()
  .._url = "/rest/active_game"
  .._constructor = (json)=> new Game.fromJson(json);

/// Serving always starts with team 0
class Game implements Model {
  final GameSchema _data;

  Game.fromJson(json) :
    _data = new GameSchema.fromJson(json);

  Game(Iterable<Player> players) : _data = new GameSchema() {
    _data.players = players.map((p)=> p.id).toList();
  }

  Game.afterGame(Game other) : _data = new GameSchema() {
    var p = other._data.players;
    List newPlayers;
    if(p.length == 2) {
      newPlayers = [p[1], p[0]];
    } else if(other._data.gameInMatch.isEven){
      newPlayers = [p[1], p[0], p[3], p[2]];
    } else {
      newPlayers = [p[3], p[2], p[1], p[0]];
    }

    _data
      ..players = newPlayers
      ..gameInMatch = other._data.gameInMatch + 1
      ..parentId = other.id;
  }

  String get id => _data.id;
  DateTime get date => _data.date;
  List<Player> get players => PlayerManager.mapFrom(_data.players);
  Team get winningTeam => _data.getScore(0) > _data.getScore(1) ? T0 : T1;
  int get totalScore => _data.totalScore;
  Point get lastPoint => _data.points.isEmpty ? null : new Point(_data.points.last);
  Team get currentServingTeam => serverIndex(totalScore, _data.players.length).isEven ? T0 : T1;

  ClientPointStreak get longestPointStreak {
    var s = _data.longestPointStreak;
    return new ClientPointStreak(new Team(s.team), s.length);
  }


  set finish(DateTime time) => _data.finish = time;

  List<Player> get shiftedPlayers {
    var pl = players;
    if(pl.length == 2) return pl;
    int svr = serverIndex(totalScore, _data.players.length);
    var result = new List.from(pl);
    if(svr == 1 || svr == 2){
      result[0] = pl[2];
      result[2] = pl[0];
    }
    if(svr == 2 || svr == 3){
      result[1] = pl[3];
      result[3] = pl[1];
    }
    return result;
  }

  bool get isComplete {
    int s0 = _data.getScore(0);
    int s1 = _data.getScore(1);
    return (s0 >= 21 || s1 >= 21) && ((s0-s1).abs() >= 2);
  }

  TeamLookup<int> get score => new TeamLookup((Team t)=> _data.getScore(t.index));
  TeamLookup<List<Player>> get team => new TeamLookup((Team t){
    var p = players;
    if(t == T0){
      return p.length == 2 ? [p[0]] : [p[0],p[2]];
    } else {
      return p.length == 2 ? [p[1]] : [p[1],p[3]];
    }
  });


  int compareTo(Game o)=> Comparable.compare(_data.date, o._data.date);

  Map toJson()=> _data.toJson();

  bool addPointByTeam(Team t){
    if(isComplete) return false;
    _data.points.add(t.index + 1);
    return true;
  }

  bool addBadServe(){
    if(isComplete) return false;
    int otherNdx = currentServingTeam.other.index + 1;
    _data.points.add(-otherNdx);
    return true;
  }

  void undoLastPoint(){
    _data.points.removeLast();
  }

  void switchSides(){
    var players = _data.players;
    players.add(players.removeAt(0));
    _data.players = players;
  }
}

class TeamLookup<T> {
  final Function f;
  TeamLookup(this.f);

  T operator[] (Team t)=> f(t);
}

class Point {
  final Team team;
  final bool badServe;

  Point(int i) :
    team = new Team(i.abs()-1),
    badServe = i < 0;
}

class ClientPointStreak {
  final Team team;
  final int length;
  ClientPointStreak(this.team, this.length);
}
