library pingpong.tests.setup;

import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';

var _gameDate = new DateTime.now();

Future setUpIntegrationData(Db db) {
  var players = db.collection('players');
  var games = db.collection('games');
  return players.insertAll([
      _player('active-1', id: 1, active: true, frequent: true),
      _player('active-2', id: 2, active: true, frequent: true),
      _player('active-3', id: 3, active: true, frequent: true),
      _player('active-4', id: 4, active: true, frequent: true),
      _player('guest-1', id: 5, guest: true, active:true),
      _player('guest-2', id: 6, guest: true, active:true),
  ]).then((_){
    return games.insertAll([
      //21 v 19
      _game([1,2,3,4],[1,2,2,1,2,1,1,1,2,1,1,1,2,1,2,2,2,2,2,2,2,2,1,2,1,1,1,1,1,1,2,1,2,2,2,1,1,1,2,1]),
      //21 v 11
      _game([2,1,4,3],[1,1,2,2,1,1,1,1,2,1,1,1,1,2,2,2,1,2,2,1,1,1,1,1,2,2,1,1,1,2,1,1]),
      //29 v 31
      _game([3,4,1,2],[-2,-1,-1,1,1,1,2,2,2,1,2,1,2,2,2,2,2,2,1,1,1,1,2,2,1,2,2,1,1,1,2,2,2,1,1,2,2,2,2,2,2,1,2,1,1,1,1,2,1,2,1,1,1,2,1,1,1,2,2,-2]),
      //21 v 14
      _game([1,3,2,4],[2,1,2,1,1,1,2,2,2,1,2,2,1,2,1,1,2,1,1,1,1,2,1,1,2,2,2,1,2,1,1,1,1,1,1]),
      //21 v 15
      _game([3,1,4,2],[2,1,1,1,2,2,1,1,1,1,2,2,1,1,1,1,1,1,1,2,1,1,2,2,2,1,2,2,2,2,2,1,1,1,2,1]),
      //18 v 21
      _game([1,2],[1,2,2,2,2,-1,-1,-1,2,2,2,2,1,2,1,1,2,2,1,1,2,2,2,1,2,2,1,2,2,1,1,1,1,2,1,1,2,2,1]),
      //22 v 20
      _game([2,1],[1,2,2,2,1,1,1,1,-2,-2,1,2,1,1,1,2,1,2,1,1,1,1,2,2,2,1,2,2,2,1,2,1,1,1,1,2,2,2,2,1,1,-2]),
      //27 v 25
      _game([1,2],[1,1,2,1,1,2,2,2,2,2,2,2,1,2,2,1,1,1,1,1,2,1,2,2,1,2,2,1,2,2,1,1,1,1,1,2,1,1,2,2,2,1,2,1,1,1,1,2,2,1,2,1]),
    ]);
  });
}

_player(String name, {id, guest:false, active: false, frequent:false}) {
  return {
      '_id': _oid(id),
      'name': name,
      'guest': guest,
      'active': active,
      'frequent': frequent,
  };
}

_game(List<int> players, List points){
  var date = _gameDate;
  _gameDate = date.add(const Duration(hours:1));
  return {
      'players': players.map(_oid).toList(),
      'points': points,
      'date': date,
      'finish': new DateTime.now(),
      'gameInMatch': 0,
  };
}

_oid(int i) =>new ObjectId.fromHexString(i.toRadixString(16).padLeft(24,'0'));
