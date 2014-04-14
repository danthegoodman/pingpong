package us.kirchmeier.pingpong.ws

import ratpack.handling.Context
import ratpack.websocket.WebSocket
import ratpack.websocket.WebSocketClose
import ratpack.websocket.WebSocketHandler
import ratpack.websocket.WebSocketMessage
import us.kirchmeier.pingpong.model.GameModel
import us.kirchmeier.pingpong.model.PlayerModel
import us.kirchmeier.pingpong.report.ReportBase

import static us.kirchmeier.pingpong.mongo.GMongo.getMongo

class RecalculateReportsHandler implements WebSocketHandler {
    Context context;

    @Override
    def onOpen(WebSocket ws) throws Exception {
        def allReports = context.getAll(ReportBase)

        ws.send("Beginning Report Recalculation")
        context.background {
            def games = mongo.games.find().collect { new GameModel(it.toMap()) }
            def allPlayers = mongo.players.find().toArray().collectEntries{ [it.get('_id'), new PlayerModel(it.toMap())] }
            ws.send "Fetched ${games.size()} games"

            allReports.each{ report ->
                report.collection.remove([:])
                games.each{
                    report.update(it, allPlayers)
                }
                ws.send "Completed ${report.getClass().simpleName}"
            }
        } onError {
            ws.send("An error has occured: ${it}")
            ws.close()
            it.printStackTrace()
        } then {
            ws.send("Finished")
            ws.close()
        }

    }

    @Override
    void onClose(WebSocketClose close) throws Exception {
    }

    @Override
    void onMessage(WebSocketMessage frame) throws Exception {
    }
}
