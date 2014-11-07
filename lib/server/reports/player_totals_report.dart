library pingpong.server.report.player_totals;

import '../common.dart';

const COLLECTION = "playerTotals";

Future playerTotalsCompleter(Db db, Game g, Map<ObjectId, PlayerSchema> allPlayers){
  var collection = db.collection(COLLECTION);
  var pl = g.players;

  var points = new List<List<int>>.generate(pl.length, (_)=> <int>[]).asMap();
  var allPoints = g.data.points;
  for (var i = 0; i < allPoints.length; i++) {
    points[serverIndex(i, pl.length)].add(allPoints[i]);
  }

  var lastServer = serverIndex(allPoints.length - 1, pl.length);
  var isDoubles = g.isDoubles;
  var leftTeamWon = g.getScore(0) > g.getScore(1);
  var commands = [];
  for (var i = 0; i < pl.length; i++) {
    var won = (leftTeamWon == i.isEven);
    var increments = {
        'goodServes' : points[i].fold(0, (p, e) => p + (e.isNegative ? 0 : 1)),
        'badServes': points[i].fold(0, (p, e) => p + (e.isNegative ? 1 : 0)),
        'fatalServes' : lastServer == i && allPoints.last.isNegative ? 1 : 0,
        'doublesWins' : isDoubles && won ? 1 : 0,
        'doublesLosses' : isDoubles && !won ? 1 : 0,
        'singlesWins' : !isDoubles && won ? 1 : 0,
        'singlesLosses' : !isDoubles && !won ? 1 : 0,
    };

    commands.add(()=> collection.update({'_id': pl[i]}, {r'$inc': increments}, upsert: true));
  }

  return Future.forEach(commands, (cmd)=> cmd());
}

Future playerTotalsReportHandler(Request r){
  Db db = r.context['db'];
  var c = db.collection(COLLECTION);

  _parsePlayers(){
    return r.readAsString().then((content){
      return JSON.decode(content).map((x)=> new ObjectId.fromHexString(x)).toList();
    });
  }

  _fetchPlayers(List players)=> c.find({'_id':{r'$in': players}}).toList();

  _scrubResults(List data){
    data.forEach((x)=> x['_id'] = x['_id'].toHexString());
    return Mongo.jsonize(data);
  }

  return _parsePlayers()
    .then(_fetchPlayers)
    .then(_scrubResults);
}

