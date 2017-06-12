part of pingpong.json.schema;

class GameSchema {
  final String id;
  String clientUuid;
  int gameInMatch;
  String parentId;

  List<String> players;

  /// The scoring team is (x.abs() - 1).
  /// A bad serve is negative.
  List<int> points;
  DateTime date;
  DateTime finish;

  GameSchema() :
    id = null,
    gameInMatch = 0,
    players = new List<String>(),
    points = new List<int>(),
    date = new DateTime.now();

  GameSchema.fromJson(json) :
    id = _ObjId_fromJson(json['_id']),
    clientUuid = json['clientUuid'],
    gameInMatch = json['gameInMatch'],
    parentId = _ObjId_fromJson(json['parentId']),
    players = _List_fromJson(json['players'], _ObjId_fromJson),
    points = _List_fromJson(json['points']),
    date = _Date_fromJson(json['date']),
    finish = _Date_fromJson(json['finish']);

  Map toJson() => {
      '_id': _ObjId_toJson(id),
      'clientUuid': clientUuid,
      'gameInMatch': gameInMatch,
      'parentId': _ObjId_toJson(parentId),
      'players': _List_toJson(players, _ObjId_toJson),
      'points': _List_toJson(points),
      'date': _Date_toJson(date),
      'finish': _Date_toJson(finish),
  };

  int get totalScore => points.length;
  int getScore(int team) => points.where((x) => x.abs() == team + 1).length;

  ///Longest streak of points for one team.
  PointStreak get longestPointStreak {
    int maxLength = 0;
    int maxTeam = 0;

    int currentTeam = 0;
    int currentLength = 0;
    for (var p in points) {
      var value = p.abs();
      if (currentTeam == value) {
        currentLength++;
      } else {
        currentLength = 1;
        currentTeam = value;
      }
      if (currentLength > maxLength) {
        maxLength = currentLength;
        maxTeam = currentTeam;
      }
    }

    return new PointStreak(maxLength, maxTeam-1);
  }
}

class PointStreak {
  final int length;
  final int team;
  PointStreak(this.length, this.team);
}
