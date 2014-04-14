import us.kirchmeier.pingpong.api.CompleteGameHandler
import us.kirchmeier.pingpong.api.RestartHandler
import us.kirchmeier.pingpong.report.BestGamesReport
import us.kirchmeier.pingpong.report.MatchProbabilityReport
import us.kirchmeier.pingpong.report.PlayerTotalsReport
import us.kirchmeier.pingpong.report.ReportBase

import us.kirchmeier.pingpong.rest.ActiveGameRestHandler
import us.kirchmeier.pingpong.rest.PlayerRestHandler
import us.kirchmeier.pingpong.util.ExceptionRenderer
import us.kirchmeier.pingpong.util.JsonListRenderer
import us.kirchmeier.pingpong.util.JsonMapRenderer
import us.kirchmeier.pingpong.util.JsonParser
import us.kirchmeier.pingpong.ws.RecalculateReportsHandler

import static ratpack.groovy.Groovy.ratpack
import static ratpack.websocket.WebSockets.*

System.setProperty('ratpack.port', System.getenv('PINGPONG_PORT') ?: '8000');

ratpack {
    modules {
        bind(JsonParser)
        bind(JsonMapRenderer)
        bind(JsonListRenderer)
        bind(ExceptionRenderer)

        bind(BestGamesReport)
        bind(MatchProbabilityReport)
        bind(PlayerTotalsReport)
    }

    handlers {
        get { render file('web/reports.html') }

        get 'api/restart', new RestartHandler()
        post 'api/completeGame', new CompleteGameHandler()

        get("ws/recalculate") { websocket(context, new RecalculateReportsHandler(context: context)) }

        registry.getAll(ReportBase).each{
            post "report/$it.path", it
        }
        prefix('rest/player', new PlayerRestHandler())
        prefix('rest/active_game', new ActiveGameRestHandler())

        assets('web')
        assets('public')
    }
}
