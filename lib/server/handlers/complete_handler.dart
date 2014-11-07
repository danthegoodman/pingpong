library pingpong.server.complete_handler;

import '../common.dart';

completeHandler(Request r) {
  Db db = r.context['db'];
  Game game;
  Map<ObjectId, PlayerSchema> allPlayers;

  Future _parseGame(Request r){
    return r.readAsString().then((content){
      game = new Game(JSON.decode(content));
    });
  }

  _assertGameIsCompletable(_){
    return db.collection('activeGames').count(where.id(game.id)).then((count){
      if(count != 1){
        throw new Response(412, body:'active game not found in database');
      }
      return null;
    });
  }

  _fetchPlayers(_){
    return db.collection('players').find(where.oneFrom('_id', game.players)).toList().then((playerDocs){
      var l = playerDocs.map((p)=> new PlayerSchema.fromJson(Mongo.jsonize(p)));
      allPlayers = new Map.fromIterable(l, key: (x)=> new ObjectId.fromHexString(x.id));
    });
  }

  _runCompleters(_)=> Future.forEach(COMPLETERS, (c)=> c(db, game, allPlayers));
  _saveGame(_)=> db.collection('games').insert(Mongo.mongoize(game.toJson()));
  _deleteActiveGame(_)=> db.collection('activeGames').remove(where.id(game.id));

  return _parseGame(r)
    .then(_assertGameIsCompletable)
    .then(_fetchPlayers)
    .then(_runCompleters)
    .then(_saveGame)
    .then(_deleteActiveGame)
    .then((_)=> new Response.ok('{}', headers: JSON_HEADERS))
    .catchError((res) => res, test: (e) => e is Response);
}
