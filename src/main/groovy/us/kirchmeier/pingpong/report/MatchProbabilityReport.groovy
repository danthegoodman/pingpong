package us.kirchmeier.pingpong.report

import spark.Request
import spark.Response
import us.kirchmeier.pingpong.model.GameModel
import us.kirchmeier.pingpong.model.PlayerModel

class MatchProbabilityReport extends ReportBase {
    String path = 'matchProbability'
    String collectionName = 'matchProbability'

    @Override
    void update(GameModel game, Map<Integer, PlayerModel> allPlayers) {
        def anyAreGuestPlayers = game.players.any{ allPlayers[it].guest }
        if(anyAreGuestPlayers) return;

        //Reorder the players to reduce permutations.
        def players = game.players;
        def pivotNdx = players.indexOf(players.min())
        players = players.drop(pivotNdx) + players.take(pivotNdx)

        def orderedPlayers = players.sort(false).join(',')
        def score0 = game.getScore(0)
        def score1 = game.getScore(1)
        def win0 = (score0 > score1 ? 1 : 0)
        def win1 = (score0 < score1 ? 1 : 0)
        collection.update(
                [_id: players.join(','), players: orderedPlayers],
                [$inc: [team0: win0, team1: win1, score0: score0, score1: score1]],
                [upsert: true]
        )
    }

    @Override
    Object handle(Request request, Response response, Map json) {
        def players = parsePlayers(json.players)
        if (!players) return 'Error - Two or four player ids are required in "players"';

        Map<Collection, Map> results = possibleTeamCombinations(players).collectEntries {
            [it, [players: it, team0: 0, team1: 0, score0: 0, score1: 0]]
        }

        collection.find([players: players.join(',')], [players: 0])*.toMap().each {
            def p = it.remove('_id').toString().tokenize(',').collect { it.toInteger() }
            it.players = p;
            results[p] = it
        }
        return results.values()
    }

    List<Integer> parsePlayers(def l) {
        if (!l || !(l instanceof List)) return null
        if (l.size() != 2 && l.size() != 4) return null
        return l.sort()
    }

    List<List> possibleTeamCombinations(List players){
        List first = players.take(1)
        return players.drop(1).permutations { first + it }
    }
}
