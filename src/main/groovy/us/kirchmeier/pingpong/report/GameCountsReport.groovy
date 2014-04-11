package us.kirchmeier.pingpong.report

import spark.Request
import spark.Response
import us.kirchmeier.pingpong.model.GameModel

class GameCountsReport extends ReportBase {
    String path = 'gameCounts'
    String collectionName = 'gameCounts'

    @Override
    void update(GameModel game) {
        def players = game.players
        def team0Won = game.getScore(0) > game.getScore(1)

        players.eachWithIndex { int id, int ndx ->
            def won = team0Won == ((ndx % 2) == 0)
            collection.update(
                    [_id: id],
                    [$inc: [win: won ? 1 : 0, lose: won ? 0 : 1]],
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
