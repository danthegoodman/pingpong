package us.kirchmeier.pingpong.report

import spark.Request
import spark.Response
import us.kirchmeier.pingpong.model.GameModel
import us.kirchmeier.pingpong.model.PlayerModel

class BestGamesReport extends ReportBase {
    String path = 'bestGames'
    String collectionName = 'bestGames'

    @Override
    void update(GameModel game, Map<Integer, PlayerModel> allPlayers) {
        def allAreFreqentPlayers = game.players.every { allPlayers[it].frequent }
        if (!allAreFreqentPlayers) return;

        def record = collection.findOne()?.toMap() ?: [_id: 0];
        def updated = false;
        updated |= updateHighestScore(record, game)
        updated |= updateLowestScore(record, game)
        updated |= updateLongestPlayerStreak(record, game)
        updated |= updateLongestTeamStreak(record, game)

        if(updated){
            collection.save(record)
        }
    }

    @Override
    Object handle(Request request, Response response, Map json) {
        return collection.findOne()?.toMap() ?: [:]
    }

    private boolean updateHighestScore(Map record, GameModel game){
        Map current = record.highestScore
        if(!current || game.points.size() >= current.points.size()){
            record.highestScore = game.toMap()
            return true
        }
        return false
    }

    private boolean updateLowestScore(Map record, GameModel game){
        Map current = record.lowestScore
        if(!current || game.points.size() <= current.points.size()){
            record.lowestScore = game.toMap()
            return true
        }
        return false
    }

    private boolean updateLongestPlayerStreak(Map record, GameModel game){
        Map current = record.longestPlayerStreak

        def scorers = game.points.collect{ it[1] == '1' ? it[2] as Integer : null }
        def (length, streaker) = findLongestStreak(scorers);

        if(!current || length >= current.length){
            record.longestPlayerStreak = [
                    length: length,
                    streaker: game.players[streaker],
                    game: game.toMap(),
            ]
            return true
        }
        return false
    }

    private boolean updateLongestTeamStreak(Map record, GameModel game){
        if(game.players.size() == 2) return false;
        Map current = record.longestTeamStreak

        def teams = game.points.collect{ it[1] == '1' ? it[2] as Integer : Math.abs((it[0] as Integer)-1) }
        def (length, streaker) = findLongestStreak(teams);

        if(!current || length >= current.length){
            record.longestTeamStreak = [
                    length: length,
                    streaker: streaker,
                    game: game.toMap(),
            ]
            return true
        }
        return false
    }

    /**
     * returns [length, streaking value]
     */
    private List<Integer> findLongestStreak(List<Integer> values){
        def streaker = values[0]
        def length = -1

        def lastPlayer = values[0]
        def currentRun = 0
        values.each{
            if(lastPlayer == it && it != null){
                currentRun ++
            } else {
                currentRun = 1
            }
            lastPlayer = it
            if(currentRun > length && it != null){
                length = currentRun
                streaker = lastPlayer.toInteger()
            }
        }
        return [length, streaker]
    }
}
