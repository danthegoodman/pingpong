package us.kirchmeier.pingpong

import com.mongodb.DB
import us.kirchmeier.pingpong.model.GameModel
import us.kirchmeier.pingpong.report.ReportBase

import static us.kirchmeier.pingpong.mongo.GMongo.getMongo

class DataAggregator {
    DB oldDb, newDb

    def playerMappings = [:]
    def gamesInMatches = [:]

    void run(){
        println "Loading Games..."
        def games = mongo.games.find().collect { new GameModel(it.toMap()) }

        ReportBase.allReports.each{ report ->
            println "Aggregating ${report.getClass().simpleName}"
            report.collection.remove([:])
            games.each{
                report.update(it)
            }
        }
        println "Finished aggregation"
    }

    static void main(String[] args) {
        new DataAggregator().run();
    }
}
