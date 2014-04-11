package us.kirchmeier.pingpong.report

import spark.Request
import spark.Response
import us.kirchmeier.pingpong.model.GameModel
import us.kirchmeier.pingpong.model.PlayerModel

class ServeCountsReport extends ReportBase {
    String path = 'serveCounts'
    String collectionName = 'serveCounts'

    @Override
    void update(GameModel game, Map<Integer, PlayerModel> allPlayers) {
        def players = game.players
        def playerServes = new HashMap<Integer, Map>()
        game.points.each{ point ->
            def server = players[point[0] as int]
            def counts = playerServes.get(server, [g:0, b:0])
            def isGood = point[1] == '1'
            counts[isGood ? 'g' : 'b'] += 1
        }

        playerServes.each{ player, counts ->
            collection.update(
                    [_id: player],
                    [$inc: [good: counts.g, bad: counts.b]],
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
