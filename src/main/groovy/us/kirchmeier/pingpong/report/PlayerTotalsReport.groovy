package us.kirchmeier.pingpong.report

import ratpack.handling.Context
import spark.Request
import spark.Response
import us.kirchmeier.pingpong.model.GameModel
import us.kirchmeier.pingpong.model.PlayerModel

class PlayerTotalsReport extends ReportBase {
    String path = 'playerTotals'
    String collectionName = 'playerTotals'

    @Override
    void update(GameModel game, Map<Integer, PlayerModel> allPlayers) {
        def team0Won = game.getScore(0) > game.getScore(1)
        def isDoubles = game.players.size() == 4
        def playerServes = new HashMap<Integer, Map>()
        game.points.each{ point ->
            def server = game.players[point[0] as int]
            def counts = playerServes.get(server, [g:0, b:0])
            def isGood = point[1] == '1'
            counts[isGood ? 'g' : 'b'] += 1
        }

        game.players.eachWithIndex { int id, int index ->
            def won = team0Won == ((index % 2) == 0)
            def strNdx = String.valueOf(index)
            def points = game.points.count{ it[2] == strNdx }
            def update = [
                    doublesPoints : isDoubles ? points : 0,
                    singlesPoints : isDoubles ? 0 : points,
                    goodServes: playerServes[id].g,
                    badServes: playerServes[id].b,
                    doublesWins: isDoubles && won ? 1 : 0,
                    doublesLosses: isDoubles & !won ? 1 : 0,
                    singlesWins: !isDoubles && won ? 1 : 0,
                    singlesLosses: !isDoubles && !won ? 1 : 0,
            ]
            collection.update(
                    [_id: id],
                    [$inc: update],
                    [upsert: true]
            )
        }
    }

    @Override
    void handle(Context context) {
        def json = context.parse(Map);
        def query = [:]
        if (json.players) {
            query._id = [$in: json.players]
        }
        def cursor = collection.find(query)
        context.render cursor*.toMap()
    }
}
