package us.kirchmeier.pingpong.mongo

import com.mongodb.DB
import com.mongodb.MongoClient
import com.mongodb.MongoClientOptions
import com.mongodb.WriteConcern

class GMongo {
    private static GMongo INSTANCE

    final MongoClient client
    final DB db

    GMongo() {
        def opts = MongoClientOptions.builder().writeConcern(WriteConcern.ACKNOWLEDGED).build()
        client = new MongoClient("127.0.0.1", opts)
        db = client.getDB(System.getProperty('pingpong.db') ?: "pingpong2")
    }

    static GMongo getMongo() {
        if (!INSTANCE) {
            INSTANCE = new GMongo()
        }
        return INSTANCE
    }

    GMongoCollection getCollection(String name) {
        return new GMongoCollection(db.getCollection(name))
    }

    GMongoCollection getPlayers() { getCollection 'players' }
    GMongoCollection getActiveGames() { getCollection 'activeGames' }
    GMongoCollection getSequences() { getCollection 'seq' }
    GMongoCollection getGames() { getCollection 'games' }
}
