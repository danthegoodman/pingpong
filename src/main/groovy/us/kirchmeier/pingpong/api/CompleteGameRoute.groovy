package us.kirchmeier.pingpong.api

import spark.Request
import spark.Response
import us.kirchmeier.pingpong.model.GameModel
import us.kirchmeier.pingpong.model.PlayerModel
import us.kirchmeier.pingpong.report.ReportBase
import us.kirchmeier.pingpong.util.GRoute

import static us.kirchmeier.pingpong.mongo.GMongo.getMongo

class CompleteGameRoute implements GRoute {
    @Override
    Object handle(Request request, Response response, Map json) {
        def game = new GameModel(json)
        mongo.games.insert(json)
        def allPlayers = mongo.players.find().toArray().collectEntries{ [it.get('_id'), new PlayerModel(it.toMap())] }

        ReportBase.allReports.each {
            it.update(game, allPlayers)
        }

        mongo.activeGames.remove(_id: json._id)
        return '{}'
    }
}
