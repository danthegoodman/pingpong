import us.kirchmeier.pingpong.api.CompleteGameHandler
import us.kirchmeier.pingpong.api.RestartHandler
import us.kirchmeier.pingpong.report.ReportBase
import us.kirchmeier.pingpong.rest.ActiveGameRestHandler
import us.kirchmeier.pingpong.rest.PlayerRestHandler
import us.kirchmeier.pingpong.util.JsonListRenderer
import us.kirchmeier.pingpong.util.JsonMapRenderer
import us.kirchmeier.pingpong.util.JsonParser

import static ratpack.groovy.Groovy.ratpack

System.setProperty('ratpack.port', System.getenv('PINGPONG_PORT') ?: '8000');

ratpack {
    modules {
        bind(JsonParser, new JsonParser())
        bind(JsonMapRenderer, new JsonMapRenderer())
        bind(JsonListRenderer, new JsonListRenderer())
    }

    handlers {
        get { render file('web/reports.html') }
        get '/api/restart', new RestartHandler()
        post '/api/completeGame', new CompleteGameHandler()

        ReportBase.allReports.each {
            post "/report/$it.path", it
        }

        prefix('/rest/player', new PlayerRestHandler())
        prefix('/rest/active_game', new ActiveGameRestHandler())

        assets('web')
        assets('public')
    }
}
