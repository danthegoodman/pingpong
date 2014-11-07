library pingpong.server.reports.best_games;

import 'dart:math' as math;
import '../common.dart';
import 'package:collection/equality.dart';

const COLLECTION = "bestGames";

Future bestGamesCompleter(Db db, Game game, Map<ObjectId, PlayerSchema> allPlayers){
  var collection = db.collection(COLLECTION);
  var allPlayersAreFrequent = game.players.every((p) => allPlayers[p].frequent);
  if (!allPlayersAreFrequent) return new Future.value();

  return collection.findOne().then((record) {
    var data = record == null ? {} : new Map.from(record);
    var streakField = game.isDoubles ? 'doublesLongestStreak' : 'singlesLongestStreak';

    var update = _buildUpdater(data, game);
    update('highestScore', math.max, (Game g)=> g.totalScore);
    update('lowestScore', math.min, (Game g)=> g.totalScore);
    update(streakField, math.max, (Game g)=> g.longestPointStreak.length);

    if (const MapEquality().equals(record, data)) return new Future.value();
    return collection.save(data);
  });
}

Future bestGamesReportHandler(Request r){
  Db db = r.context['db'];
  var c = db.collection(COLLECTION);

  return c.findOne(where.excludeFields(['_id'])).then((data) {
    return data == null ? new Map() : Mongo.jsonize(data);
  });
}

DataUpdater _buildUpdater(Map record, Game game){
  return (String name, Function comparer, dataProvider){
    var existingJson = record[name];
    if(existingJson != null){
      var existingGame = new Game(Mongo.jsonize(existingJson));
      var newVal = dataProvider(game);
      var oldVal = dataProvider(existingGame);
      if(!identical(newVal, oldVal)){
        var val = comparer(newVal, oldVal);
        if(identical(oldVal,val)) return;
      }
    }
    record[name] = Mongo.mongoize(game.toJson());
  };
}

typedef DataUpdater(String field, comparator(a,b), gameDataProvider(Game g));
