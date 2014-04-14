package us.kirchmeier.pingpong

import com.mongodb.BasicDBObject
import com.mongodb.DB
import org.bson.types.ObjectId
import us.kirchmeier.pingpong.api.CompleteGameHandler
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

        newDb.getCollection('seq').insert(new BasicDBObject(_id: 'players', seq: playerId))
        println "Copied ${oldPlayers.size()} Players"
    }

    private void copyGames(){
        int gameIndex = 0;
        def gameCompleter = new CompleteGameHandler()
        def warnings = []

        oldDb.getCollection('games').find().skip(gameIndex).toArray().each { oldGame ->
            if(gameIndex % 100 == 0) println "  Copying game and points ${gameIndex}"
            gameIndex++

            def og = oldGame.toMap();
            def team0 = og.team0.collect { playerMappings[it] }
            def team1 = og.team1.collect { playerMappings[it] }
            def players = [team0[0], team1[0], team0[1], team1[1]] - null;
            def points = buildPointList(warnings, og, players);
            def gameInMatch = og.gameCount ?: gamesInMatches[og.parent] ?: 0
            gamesInMatches[og._id] = gameInMatch + 1

            if(!points){
                warnings << "Skipped with no points - ${og._id}"
                return;
            }

            gameCompleter.completeGame([
                    _id        : og._id,
                    gameInMatch: gameInMatch,
                    parentId   : og.parent,
                    date       : og.date,
                    finish     : og.finish,
                    players    : players,
                    points     : points,
            ])
        }

        println "Copied ${gameIndex} Games"
        warnings.each{ println "  $it" }
    }

    List<String> buildPointList(List warnings, Map og, List players){
        if(!og.score0 && !og.score1) return null;

        scrubScores(warnings, og);
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

    void scrubScores(List warnings, Map og){
        List s0 = og.score0;
        List s1 = og.score1;
        List hist = og.scoreHistory;

        if(s0.size() < 21 && s1.size() < 21) {
            warnings << "Game is not complete ($s0 - $s1) - $og._id"
            return;
        }

        def rem0 = {
            s0.pop();
            hist.pop();
            warnings << "Removed extra point from team 0 - $og._id"
        }

        def rem1 = {
            s1.pop();
            hist.pop();
            warnings << "Removed extra point from team 1 - $og._id"
        }

        while(s0.size() > 21 && s1.size() < 20){
            rem0()
        }

        while(s1.size() > 21 && s0.size() < 20){
            rem1()
        }

        while(s0.size() >= 20 && s1.size() >= 20 && Math.abs(s0.size() - s1.size()) > 2){
            if(s0.size() > s1.size()) rem0();
            else rem1();
        }
    }

    static void main(String[] args) {
        new DataMigrator().run();
    }
}
