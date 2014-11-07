library pingpong.server.reports;

import 'common.dart';
import 'reports/best_games_report.dart';
import 'reports/ideal_team_report.dart';
import 'reports/player_totals_report.dart';

const REPORTS = const <String, Handler> {
  '/report/bestGames': bestGamesReportHandler,
  '/report/idealTeam': idealTeamReportHandler,
  '/report/playerTotals': playerTotalsReportHandler,
};

const COMPLETERS = const <GameCompleter>[
    bestGamesCompleter,
    idealTeamCompleter,
    playerTotalsCompleter,
];

typedef Future GameCompleter(Db db, Game game, Map<ObjectId, PlayerSchema> allPlayers);

Handler reportsAdapter(Function f) =>
  (Request req) {
    return f(req).then((result){
      if(result is Response) return result;
      return new Response.ok(JSON.encode(result), headers: JSON_HEADERS);
    });
  };
