package us.kirchmeier.pingpong.api

import ratpack.handling.Context
import ratpack.handling.Handler
import us.kirchmeier.pingpong.model.GameModel
import us.kirchmeier.pingpong.model.PlayerModel
import us.kirchmeier.pingpong.report.ReportBase

import static us.kirchmeier.pingpong.mongo.GMongo.getMongo

class CompleteGameHandler implements Handler {
    @Override
    void handle(Context context) {
        def json = context.parse(Map);
        context.background {
            completeGame(json, getAll(ReportBase))
        } onError {
            context.render it
        } then {
            context.render '{}'
        }
    }

    void completeGame(Map json, List<ReportBase> reports) {
        def game = new GameModel(json)

        mongo.games.insert(json)
        def allPlayers = mongo.players.find().toArray().collectEntries { [it.get('_id'), new PlayerModel(it.toMap())] }

        reports.each {
            it.update(game, allPlayers)
        }

        mongo.activeGames.remove(_id: json._id)
    }
}
