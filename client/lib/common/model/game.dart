part of us.kirchmeier.pingpong.common.models;

ModelManager<Game> GameManager = new ModelManager<Game>()
  .._url = "/game"
  .._constructor = ()=> new Game();

/// Serving always starts with team 0
class Game extends Model {
  String id;
  String parentId; // Game
  String tournamentId;
  DateTime date;
  DateTime finish;
  int gameInMatch;
  List<String> _team0; //Player IDs
  List<String> _team1;
  List<String> _points0; //Point IDs
  List<String> _points1;
  List<int> scoreHistory; //Who scored, 0 or 1?
  bool inProgress;

  Game();

  Game.brandNew(){
    date = new DateTime.now();
    gameInMatch = 0;
    inProgress = true;
    _team0 = [];
    _team1 = [];
    _points0 = [];
    _points1 = [];
    scoreHistory = [];
  }

  set teams(List<Iterable<Player>> teams){
    _team0 = teams[0].map((p)=> p.id).toList(growable: false);
    _team1 = teams[1].map((p)=> p.id).toList(growable: false);
  }

  bool get isComplete {
    int s0 = _points0.length;
    int s1 = _points1.length;
    return (s0 >= 21 || s1 >= 21) && ((s0-s1).abs() >= 2);
  }

  int get totalScore => scoreHistory.length;

  int get winningTeam => _points0.length > _points1.length ? 0 : 1;

  TeamLookup<List<Player>> get team => new TeamLookup(_team0, _team1, (x)=> PlayerManager.mapFrom(x));
  TeamLookup<int> get score => new TeamLookup(_points0, _points1, (x)=> x.length);
  TeamLookup<List<String>> get points => new TeamLookup(_points0, _points1, (x)=> x);

  int compareTo(Game o)=> Comparable.compare(date, o.date);

  void fromJson(Map json){
    scoreHistory = _fromJson_List(json['scoreHistory']);
    finish = _fromJson_DateTime(json['finish']);
    _points0 = _fromJson_List(json['score0']);
    _points1 = _fromJson_List(json['score1']);
    date = _fromJson_DateTime(json['date']);
    _team0 = _fromJson_List(json['team0']);
    _team1 = _fromJson_List(json['team1']);
    tournamentId = json['tournament'];
    gameInMatch = json['gameCount'];
    inProgress = json['inProgress'];
    parentId = json['parent'];
    id = json['_id'];
  }

  Map toJson(){
    var result = {};
    if(scoreHistory != null) result['scoreHistory'] = _toJson_List(scoreHistory);
    if(_points0 != null) result['score0'] = _toJson_List(_points0);
    if(_points1 != null) result['score1'] = _toJson_List(_points1);
    if(finish != null) result['finish'] = _toJson_DateTime(finish);
    if(tournamentId != null) result['tournament'] = tournamentId;
    if(gameInMatch != null) result['gameCount'] = gameInMatch;
    if(_team0 != null) result['team0'] = _toJson_List(_team0);
    if(_team1 != null) result['team1'] = _toJson_List(_team1);
    if(date != null) result['date'] = _toJson_DateTime(date);
    if(inProgress != null) result['inProgress'] = inProgress;
    if(parentId != null) result['parent'] = parentId;
    if(id != null) result['_id'] = id;
    return result;
  }
}

class TeamLookup<T> {
  final List _obj;
  final Function f;
  TeamLookup(a, b, this.f): _obj = new List(2)..[0] = a..[1] = b;

  T operator[] (int i)=> f(_obj[i]);
}

