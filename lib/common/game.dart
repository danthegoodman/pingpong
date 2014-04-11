part of pingpong.common;

ModelManager<Game> GameManager = new ModelManager<Game>()
  .._url = "/rest/active_game"
  .._constructor = ()=> new Game.blank();

/// Serving always starts with team 0
class Game extends Model {
  String id;
  String parentId; // Game
  DateTime date;
  DateTime finish;
  int gameInMatch;
  List<int> _players;
  List<Point> points;

  Game.blank();

  Game(){
    date = new DateTime.now();
    gameInMatch = 0;
    _players = new List<int>();
    points = new List<Point>();
  }

  List<Player> get players => PlayerManager.mapFrom(_players);
  set players(Iterable<Player> players){
    _players = players.map((p)=> p.id).toList(growable: false);
  }

  bool get isComplete {
    int s0 = score[T0];
    int s1 = score[T1];
    return (s0 >= 21 || s1 >= 21) && ((s0-s1).abs() >= 2);
  }

  Team get winningTeam => score[T0] > score[T1] ? T0 : T1;

  TeamLookup<List<Player>> get team => new TeamLookup((Team t){
    var p = players;
    if(p.length == 2){
      return t == T0 ? [p[0]] : [p[1]];
    } else {
      return t == T0 ? [p[0], p[2]] : [p[1], p[3]];
    }
  });

  TeamLookup<int> get score => new TeamLookup((Team t)=> points.where((p)=> p.team == t).length);

  void addPointBy(Player p){
    var ndx = _players.indexOf(p.id);
    points.add(new Point._(_players[currentServerIndex], p.id, ndx.isEven ? T0 : T1));
  }
  
  void addBadServe(){
    var ndx = currentServerIndex;
    points.add(new Point._badServe(_players[ndx], ndx.isEven ? T1 : T0));
  }

  Team get currentServingTeam => currentServerIndex.isEven ? T0 : T1;

  int get currentServerIndex {
    var score = points.length;
    if(score < 40){
      return (score % (players.length * 5)) ~/ 5;
    } else {
      return score % players.length;
    }
  }

  int compareTo(Game o)=> Comparable.compare(date, o.date);

  void fromJson(Map json){
    _players = _fromJson_List(json['players']);
    points = _fromJson_Points(json['points'], _players);
    date = _fromJson_DateTime(json['date']);
    finish = _fromJson_DateTime(json['finish']);
    gameInMatch = json['gameInMatch'];
    parentId = _fromJSON_ObjectId(json['parentId']);
    id = _fromJSON_ObjectId(json['_id']);
  }

  Map toJson(){
    var result = {};
    if(_players != null) result['players'] = _toJson_List(_players);
    if(points != null) result['points'] = _toJson_Points(points, _players);
    if(date != null) result['date'] = _toJson_DateTime(date);
    if(finish != null) result['finish'] = _toJson_DateTime(finish);
    if(gameInMatch != null) result['gameInMatch'] = gameInMatch;
    if(parentId != null) result['parentId'] = _toJson_ObjectId(parentId);
    if(id != null) result['_id'] = _toJson_ObjectId(id);
    return result;
  }
}

class TeamLookup<T> {
  final Function f;
  TeamLookup(this.f);

  T operator[] (Team t)=> f(t);
}

class Point {
  final int _serverId;  
  final int _scorerId;
  final Team team;
  final bool isBadServe;
  Player get server => PlayerManager.get(_serverId);
  Player get scorer => PlayerManager.get(_scorerId);
  
  Point._(this._serverId, this._scorerId, this.team) : isBadServe = false;
  Point._badServe(this._serverId, this.team): isBadServe = true, _scorerId = null;
}

List<String> _toJson_Points(List<Point> pts, List<int> players){
  List result = [];
  for(int i = 0; i < pts.length; i++){
    var p = pts[i];
    var server = players.indexOf(p._serverId);
    if(p.isBadServe){
      result.add("${server}0 ");
    } else {
      var scorer = players.indexOf(p._scorerId);
      result.add("${server}1${scorer}");
    }
  }
  return result;
}

List<Point> _fromJson_Points(List<String> pts, List<int> players){
  List result = [];
  for(int i = 0; i < pts.length; i++){
    String rawPoint = pts[i];
    var serverPosition = int.parse(rawPoint[0]);
    var server = players[serverPosition];
    if(rawPoint[1] == '0'){
      var team = serverPosition.isEven ? T1 : T0;
      result.add(new Point._badServe(server, team));
    } else {
      var scorerPosition = int.parse(rawPoint[2]);
      var scorer = players[scorerPosition];
      var team = scorerPosition.isEven ? T0 : T1;
      result.add(new Point._(server, scorer, team));
    }
  }
  return result;
 }
