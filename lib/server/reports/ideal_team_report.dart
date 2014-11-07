library pingpong.server.reports.ideal_team;

import '../common.dart';

const IDEAL_HISTORY_LIMIT = 150;
const COLLECTION = 'idealTeam';

Future idealTeamCompleter(Db db, Game game, Map<ObjectId, PlayerSchema> allPlayers){
    var anyAreGuestPlayers = game.players.any((id)=> allPlayers[id].guest);
    if(anyAreGuestPlayers) return new Future.value();

    var sortedPlayers = new List.from(game.data.players)..sort();

    var score0 = game.getScore(0);
    var score1 = game.getScore(1);
    var idealness = ((score0 < score1 ? score0 : score1)/17) - 1;

    var result = {
        'players': sortedPlayers.join(','),
        'team': game.teamId,
        'date': game.data.date,
        'score': idealness,
    };
    return db.collection(COLLECTION).insert(result);
}

Future idealTeamReportHandler(Request r){
  Db db = r.context['db'];
  var c = db.collection(COLLECTION);
  List<String> players;

  _parsePlayers(String content) {
    players = JSON.decode(content)['players'];
    if (players.length != 2 && players.length != 4) {
      throw new Response(412, body:'Error: Two or four player ids are required in "players"');
    }
    players.sort();
  }

  _queryResults(_){
    var sel = where
        .eq('players', players.join(','))
        .sortBy('date', descending: true);
    return c.find(sel).toList();
  }

  _buildResponse(List<Map> data) {
    var teamScores = new Map.fromIterable(_teamCombinations(players), value: (_) => []);
    data.forEach((x) {
      teamScores[x['team']].add(x['score']);
    });

    return new Map.fromIterables(teamScores.keys, teamScores.values.map(_buildTeamResponse));
  }

  return r.readAsString()
    .then(_parsePlayers)
    .then(_queryResults)
    .then(_buildResponse)
    .catchError((res) => res, test: (e) => e is Response);
}

List<String> _teamCombinations(List p) {
  if(p.length == 2) return ["${p.first}-${p.last}"];
  return [
      "${p[0]},${p[1]}-${p[2]},${p[3]}",
      "${p[0]},${p[2]}-${p[1]},${p[3]}",
      "${p[0]},${p[3]}-${p[1]},${p[2]}",
  ];
}

_buildTeamResponse(List<num> values) => {
    'games': values.length,
    'score': rollingAverage(values, IDEAL_HISTORY_LIMIT),
};
