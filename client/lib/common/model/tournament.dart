part of us.kirchmeier.pingpong.common.models;

ModelManager<Tournament> TournamentManager = new ModelManager<Tournament>()
  .._url = "/tournament"
  .._constructor = ()=> new Tournament();

class Tournament extends Model{
  String id;
  DateTime date;
  List<String> _players;
  String title;
  String type;
  var table; //Data map, structure based on type
  bool inProgress;
  bool isSingles;

  List<Player> get players => PlayerManager.mapFrom(_players);
  set players (List<Player> plist)=> _players = new List.from(plist.map((p)=> p.id));

  Tournament();

  Tournament.brandNew():
    date = new DateTime.now(),
    _players = [],
    inProgress = true,
    isSingles = true;

  int compareTo(Tournament o)=> Comparable.compare(date, o.date);

  void fromJson(Map json){
    _players = _fromJson_List(json['players']);
    date = _fromJson_DateTime(json['date']);
    id = json['_id'];
    inProgress = json['inProgress'];
    isSingles = json['isSingles'];
    title = json['title'];
    table = json['table'];
    type = json['type'];
  }

  Map toJson(){
    var result = {};
    if(_players != null) result['players'] = _toJson_List(_players);
    if(date != null) result['date'] = _toJson_DateTime(date);
    if(id != null) result['_id'] = id;
    if(inProgress != null) result['inProgress'] = inProgress;
    if(isSingles != null) result['isSingles'] = isSingles;
    if(title != null) result['title'] = title;
    if(table != null) result['table'] = table;
    if(type != null) result['type'] = type;
    return result;
  }
}


