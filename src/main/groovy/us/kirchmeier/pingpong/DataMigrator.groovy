package us.kirchmeier.pingpong

import com.mongodb.BasicDBObject
import com.mongodb.DB
import org.bson.types.ObjectId
import us.kirchmeier.pingpong.api.CompleteGameRoute
import us.kirchmeier.pingpong.report.ReportBase

import static us.kirchmeier.pingpong.mongo.GMongo.getMongo

class DataMigrator {
    DB oldDb, newDb

    def playerMappings = [:]
    def gamesInMatches = [:]

    void run(){
        ReportBase.allReports
        oldDb = mongo.client.getDB('pingpong')
        newDb = mongo.client.getDB('pingpong2')
        newDb.dropDatabase()
        println "Starting afresh..."

        copyPlayers()
        copyGames()
    }

    private void copyPlayers() {
        def oldPlayers = oldDb.getCollection('players').find().toArray()

        int playerId = 1;
        newDb.getCollection('players').insert(oldPlayers.collect {
            playerMappings[it.get('_id')] = playerId
            it.put('_id', playerId)
            it.removeField('__v')
            playerId++
            return it
        })

        newDb.getCollection('seq').insert(new BasicDBObject(_id: 'player', seq: playerId))
        println "Copied Players"
    }

    private void copyGames(){
        int gameIndex = 0;
        def gameCompleter = new CompleteGameRoute()

        oldDb.getCollection('games').find().skip(gameIndex).toArray().each { oldGame ->
            if(gameIndex % 100 == 0) println "Copying game and points ${gameIndex}"
            gameIndex++

            def og = oldGame.toMap();
            def team0 = og.team0.collect { playerMappings[it] }
            def team1 = og.team1.collect { playerMappings[it] }
            def players = [team0[0], team1[0], team0[1], team1[1]] - null;
            def points = buildPointList(og, players);
            def gameInMatch = og.gameCount ?: gamesInMatches[og.parent] ?: 0
            gamesInMatches[og._id] = gameInMatch + 1

            if(!points){
                println "  NO POINTS, SKIPPING GAME ${og._id}"
                return;
            }

            gameCompleter.handle(null, null, [
                    _id        : og._id,
                    gameInMatch: gameInMatch,
                    parentId   : og.parent,
                    date       : og.date,
                    finish     : og.finish,
                    players    : players,
                    points     : points,
            ])
        }
    }

    List<String> buildPointList(Map og, List players){
        int s0 = og.score0.size()
        int s1 = og.score1.size()

        if(s0 + s1 == 0){
            return null;
        } else if(s0 < 21 && s1 < 21) {
            println "  Game is not complete ($s0 - $s1) $og._id"
        } else if ((s0 > 21 && s1 < 20) || (s1 > 21 && s0 < 20)) {
            println "  Game ended with too many points ($s0 - ${s1}) $og._id"
        } else if(s0 >= 20 && s1 >= 20 && Math.abs(s0 - s1) > 2){
            println "  Game point spread is too great ($s0 - $s1) $og._id"
        }

        def oldPoints = oldDb.getCollection('points').find(new BasicDBObject(_id: [$in: (og.score0 + og.score1)]))
        Map<ObjectId, Map> oldPointMap = oldPoints.iterator().collectEntries { [it.get('_id'), it.toMap()]}

        def oldScores = [og.score0.reverse(), og.score1.reverse()]
        def oldPointsInOrder = og.scoreHistory.collect { oldPointMap[oldScores[it].pop()] }

        return oldPointsInOrder.collect { Map oldPoint ->
            def servingPlayer = players.indexOf(playerMappings[oldPoint.server])
            def scoringIndex = players.indexOf(playerMappings[oldPoint.scoringPlayer])

            if (oldPoint.badServe) return "${servingPlayer}0 "
            return "${servingPlayer}1${scoringIndex}"
        }*.toString()
    }

    static void main(String[] args) {
        new DataMigrator().run();
    }
}
