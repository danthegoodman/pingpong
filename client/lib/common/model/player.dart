part of us.kirchmeier.pingpong.common.models;

ModelManager<Player> PlayerManager = new ModelManager<Player>()
.._url = "/player"
.._constructor = ()=> new Player();

class Player extends Model {
  String id;
  String name;
  bool active;

  Player();

  Player.brandNew():
     name = "New Player",
     active = true;

  int compareTo(Player o)=> Comparable.compare("$name", "${o.name}");

  void fromJson(Map json){
    id = json['_id'];
    name = json['name'];
    active = json['active'];
  }

  Map toJson(){
    var result = {};
    if(id != null) result['_id'] = id;
    if(name != null) result['name'] = name;
    if(active != null) result['active'] = active;
    return result;
  }

  String toString() => name;
}