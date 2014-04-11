package us.kirchmeier.pingpong.rest

import us.kirchmeier.pingpong.mongo.GMongoCollection

import static us.kirchmeier.pingpong.mongo.GMongo.getMongo

class ActiveGameRestRouter extends ModelRestRouter {

    String path = 'active_game'

    @Override
    GMongoCollection getCollection() {
        return mongo.activeGames
    }
}
