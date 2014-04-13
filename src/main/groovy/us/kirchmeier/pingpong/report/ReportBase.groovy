package us.kirchmeier.pingpong.report

import groovy.transform.Memoized
import org.reflections.Reflections
import ratpack.handling.Context
import ratpack.handling.Handler
import us.kirchmeier.pingpong.model.GameModel
import us.kirchmeier.pingpong.model.PlayerModel
import us.kirchmeier.pingpong.mongo.GMongo
import us.kirchmeier.pingpong.mongo.GMongoCollection


abstract class ReportBase implements Handler{
    GMongoCollection getCollection() {
        return GMongo.mongo.getCollection(collectionName)
    }

    abstract String getCollectionName()
    abstract String getPath()

    abstract void update(GameModel game, Map<Integer, PlayerModel> allPlayers)
    abstract void handle(Context context)

    @Memoized(protectedCacheSize = 1)
    static Collection<ReportBase> getAllReports() {
        Reflections reflections = new Reflections("us.kirchmeier.pingpong");
        return reflections.getSubTypesOf(ReportBase.class)*.newInstance()
    }

}
