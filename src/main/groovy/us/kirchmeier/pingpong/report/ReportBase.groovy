package us.kirchmeier.pingpong.report

import groovy.transform.Memoized
import org.reflections.Reflections
import spark.Request
import spark.Response
import us.kirchmeier.pingpong.model.GameModel
import us.kirchmeier.pingpong.model.PlayerModel
import us.kirchmeier.pingpong.mongo.GMongo
import us.kirchmeier.pingpong.mongo.GMongoCollection
import us.kirchmeier.pingpong.util.GRoute


abstract class ReportBase implements GRoute{
    GMongoCollection getCollection() {
        return GMongo.mongo.getCollection(collectionName)
    }

    abstract String getCollectionName()
    abstract String getPath()

    abstract void update(GameModel game, Map<Integer, PlayerModel> allPlayers)
    abstract Object handle(Request request, Response response, Map jsonBody)

    @Memoized(protectedCacheSize = 1)
    static Collection<ReportBase> getAllReports() {
        Reflections reflections = new Reflections("us.kirchmeier.pingpong");
        return reflections.getSubTypesOf(ReportBase.class)*.newInstance()
    }

}
