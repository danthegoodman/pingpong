package us.kirchmeier.pingpong.report

import spark.Request
import spark.Response
import us.kirchmeier.pingpong.model.GameModel
import us.kirchmeier.pingpong.model.PlayerModel

class PointTotalsReport extends ReportBase {
    String path = 'pointTotals'
    String collectionName = 'pointTotals'

    @Override
    void update(GameModel game, Map<Integer, PlayerModel> allPlayers) {
        def players = game.players
        def points = game.points

        players.eachWithIndex { int id, int index ->
            def strNdx = String.valueOf(index)
            int total = points.count{ it[2] == strNdx }
            collection.update(
                    [_id: id],
                    [$inc: [total: total]],
                    [upsert: true]
            )
        }
    }

    @Override
    Object handle(Request request, Response response, Map json) {
        def query = [:]
        if (json.players) {
            query._id = [$in: json.players]
        }
        def cursor = collection.find(query)
        return cursor*.toMap()
    }
}
