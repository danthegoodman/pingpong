library pingpong.server.recalculate_handler;

import 'package:http_parser/http_parser.dart';
import '../common.dart';

final _LOG = new Logger('recalculate');
const RETAIN_COLLECTIONS = const ['players', 'activeGames', 'games'];

recalculateHandler(CompatibleWebSocket ws) {
  ws.drain(); //We don't care about incoming messages.
  ws.add("Beginning Report Recalculation");
  return Mongo.withConnection((Db db){
    List<Game> games;
    Map<ObjectId, PlayerSchema> allPlayers;

    Future _fetchGames(){
      return db.collection('games').find().toList().then((l){
        games = l.map((g)=> new Game(Mongo.jsonize(g))).toList();
        ws.add("Fetched ${games.length} games");
      });
    }

    _fetchPlayers(_){
      return db.collection('players').find().toList().then((l){
        allPlayers = new Map.fromIterable(l, key: (p)=> p['_id'], value: (p)=> new PlayerSchema.fromJson(Mongo.jsonize(p)));
        ws.add("Fetched ${allPlayers.length} players");
      });
    }

    _dropCollections(_){
      return db.listCollections().then((l){
        RETAIN_COLLECTIONS.forEach(l.remove);
        return Future.forEach(l, db.dropCollection).then((_){
          ws.add("Dropped ${l.length} collections");
        });
      });
    }

    _recalculate(GameCompleter gc){
      return Future.forEach(games, (g)=> gc(db, g, allPlayers)).then((_){
        ws.add("Updated a report");
      });
    }

    _handleError(err, StackTrace st){
      _LOG.severe("Recalculation Error", err, st);
      ws.add("An error has occured: ${err}");
    }

    return _fetchGames()
      .then(_fetchPlayers)
      .then(_dropCollections)
      .then((_)=> Future.forEach(COMPLETERS, _recalculate))
      .then((_)=> ws.add("Finished"))
      .catchError(_handleError)
      .whenComplete(ws.close);
  });
}
