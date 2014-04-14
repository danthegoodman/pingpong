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

    /**
     * The name of the collection in mongo.
     */
    abstract String getCollectionName()

    /**
     * The path to serve the report. Do not include the 'report/' prefix.
     */
    abstract String getPath()

    /**
     * Updates the report upon the completion of [:game:].
     *
     * [:allPlayers:] contains a map of all of the known players, mapped by ID.
     */
    abstract void update(GameModel game, Map<Integer, PlayerModel> allPlayers)

    /**
     * Handles the report request in a background thread as to not block.
     *
     * Return the result to render, do not use [:context'} to render.
     */
    abstract Object handleBackground(Context context)

    @Override
    void handle(Context context) throws Exception {
        context.background {
            handleBackground(context)
        }.onError {
            context.render it
        }.then {
            context.render it
        }
    }

    @Memoized(protectedCacheSize = 1)
    static Collection<ReportBase> getAllReports() {
        Reflections reflections = new Reflections("us.kirchmeier.pingpong");
        def reports = reflections.getSubTypesOf(ReportBase.class)*.newInstance()
        return reports.sort { it.class.simpleName }
    }

}
