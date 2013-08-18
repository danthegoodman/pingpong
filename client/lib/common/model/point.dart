part of us.kirchmeier.pingpong.common.models;

ModelManager<Point> PointManager = new ModelManager<Point>()
  .._url = "/point"
  .._constructor = ()=> new Point();

class Point extends Model{
  String id;
  String game;
  String server;
  String receiver;
  String serverPartner;
  String receiverPartner;
  String scoringPlayer;
  bool badServe;

  Point();

  Point.brandNew():
    badServe = false;

  int compareTo(Point o)=> 0;

  void fromJson(Map json){
    id = json['_id'];
    game = json['game'];
    server = json['server'];
    receiver = json['receiver'];
    serverPartner = json['serverPartner'];
    receiverPartner = json['receiverPartner'];
    scoringPlayer = json['scoringPlayer'];
    badServe = json['badServe'];
  }
  Map toJson(){
    var result = {};
    if(id != null) result['_id'] = id;
    if(game != null) result['game'] = game;
    if(server != null) result['server'] = server;
    if(receiver != null) result['receiver'] = receiver;
    if(serverPartner != null) result['serverPartner'] = serverPartner;
    if(receiverPartner != null) result['receiverPartner'] = receiverPartner;
    if(scoringPlayer != null) result['scoringPlayer'] = scoringPlayer;
    if(badServe != null) result['badServe'] = badServe;
    return result;
  }
}

