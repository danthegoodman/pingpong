part of pingpong.common;

ModelManager<Player> PlayerManager = new ModelManager<Player>()
  .._url = "/rest/player"
  .._constructor = (json) => new Player.fromJson(json);


class Player extends PlayerSchema implements Model {
  Player.fromJson(json) : super.fromJson(json);

  Player.brandNew() {
    name = "New Player";
    active = true;
  }

  int compareTo(Player o) => Comparable.compare(name, o.name);

  String toString() => name;
}
