package us.kirchmeier.pingpong.api

import ratpack.handling.Context
import ratpack.handling.Handler
import ratpack.server.Stopper
import us.kirchmeier.pingpong.model.GameModel
import us.kirchmeier.pingpong.model.PlayerModel
import us.kirchmeier.pingpong.report.ReportBase

import static us.kirchmeier.pingpong.mongo.GMongo.getMongo

class RestartHandler implements Handler {
    @Override
    void handle(Context context) {
        println "OHKO! Fatality. Restarting Server."
        context.get(Stopper).stop();
    }
}
