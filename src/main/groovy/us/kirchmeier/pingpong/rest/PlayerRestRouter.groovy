package us.kirchmeier.pingpong.rest

import us.kirchmeier.pingpong.mongo.GMongoCollection

import static us.kirchmeier.pingpong.mongo.GMongo.getMongo

class PlayerRestRouter extends ModelRestRouter {

    String path = 'player'

    GMongoCollection getCollection(){
        mongo.players
    }

    @Override
    Map create(Map model) {
        def idVal = mongo.sequences.findAndModify([_id: 'players'], [$inc: [seq: 1]]).toMap()
        model._id = model[idVal.seq];
        return super.create(model)
    }
}
