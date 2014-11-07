library pingpong.server.common;

import 'dart:io' show HttpHeaders;
import '../common/schema.dart';
import 'util/mongo.dart';

export 'dart:async';
export 'dart:convert';
export 'package:logging/logging.dart';
export 'package:shelf/shelf.dart';

export '../common/schema.dart';
export '../common/functions.dart';
export 'util/mongo.dart';
export 'reports.dart';

const JSON_HEADERS = const {HttpHeaders.CONTENT_TYPE: 'application/json'};

class Game {
  final GameSchema data;

  Game(jsonData) : data = new GameSchema.fromJson(jsonData);

  ObjectId get id => new ObjectId.fromHexString(data.id);
  List<ObjectId> get players => data.players.map((x) => new ObjectId.fromHexString(x)).toList();
  bool get isDoubles => data.players.length == 4;

  int get totalScore => data.totalScore;
  PointStreak get longestPointStreak => data.longestPointStreak;

  int getScore(int team)=> data.getScore(team);
  Map toJson() => data.toJson();

  String get teamId {
    var pl = data.players;
    List t;
    if(pl.length == 4){
      var a = [pl[0], pl[2]]..sort();
      var b = [pl[1], pl[3]]..sort();
      t = [a.join(','),b.join(',')];
    } else {
      t = new List.from(pl);
    }
    t.sort();
    return t.join('-');
  }
}
