package us.kirchmeier.pingpong.rest

import us.kirchmeier.pingpong.mongo.GMongoCollection

import static us.kirchmeier.pingpong.mongo.GMongo.getMongo

class ActiveGameRestHandler extends ModelRestHandler {

    @Override
    GMongoCollection getCollection() {
        return mongo.activeGames
    }
}
