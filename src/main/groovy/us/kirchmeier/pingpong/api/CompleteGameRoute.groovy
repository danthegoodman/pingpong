package us.kirchmeier.pingpong.api

import spark.Request
import spark.Response
import us.kirchmeier.pingpong.model.GameModel
import us.kirchmeier.pingpong.report.ReportBase
import us.kirchmeier.pingpong.util.GRoute

import static us.kirchmeier.pingpong.mongo.GMongo.getMongo

class CompleteGameRoute implements GRoute {
    @Override
    Object handle(Request request, Response response, Map json) {
        def game = new GameModel(json)
        mongo.games.insert(json)

        ReportBase.allReports.each {
            it.update(game)
        }

        mongo.activeGames.remove(_id: json._id)
        return '{}'
    }

//    private void savePoints(def gameId, List<Integer> players, List rawPoints) {
//        def playerSize = players.size()
//        def points = []
//        def playerServes = new HashMap<Integer, ServeTotaler>()
//        rawPoints.each { String point ->
//            def server = players[point[0] as int]
//            if (point[1] == '1') {
//                def scorer = point[2] as int
//                points << [
//                        game  : gameId,
//                        player: players[scorer],
//                        to    : players[(scorer + 1) % playerSize],
//                        from  : players[(scorer - 1 + playerSize) % playerSize],
//                ]
//            }
//            playerServes.get(server, new ServeTotaler()).include(point)
//        }
//
//        mongo.points.insert(points)
//        mongo.serves.insert(playerServes.collect { k, v ->
//            [
//                    game  : gameId,
//                    player: players[k],
//                    good  : v.good,
//                    bad   : v.bad,
//            ]
//        })
//    }
}
