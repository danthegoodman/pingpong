package us.kirchmeier.pingpong

import spark.Filter
import spark.Spark
import us.kirchmeier.pingpong.api.CompleteGameRoute
import us.kirchmeier.pingpong.mongo.GMongo
import us.kirchmeier.pingpong.report.ReportBase
import us.kirchmeier.pingpong.rest.ActiveGameRestRouter
import us.kirchmeier.pingpong.rest.PlayerRestRouter
import us.kirchmeier.pingpong.util.GRoute
import us.kirchmeier.pingpong.util.Sparky
import us.kirchmeier.pingpong.util.DartFileRoutes

class Server {
    public static final boolean isProduction = System.getProperty('pinpong.prod').asBoolean()
    static void main(String[] args) {
        def directory = System.getProperty('user.dir')

        Spark.port = System.getenv('PINGPONG_PORT')?.toInteger() ?: 8000
        Spark.externalStaticFileLocation("${directory}/public")
        Spark.before(addCORSHeaders)

        Sparky.get '/', onIndexRoute

        Sparky.get '/api/restart', onFatalRoute
        Sparky.post '/api/completeGame', new CompleteGameRoute()

        ReportBase.allReports.each{
            Sparky.post "/report/$it.path", it
        }

        new PlayerRestRouter().install()
        new ActiveGameRestRouter().install()

        Spark.get new DartFileRoutes()
    }

    private static GRoute onIndexRoute = { req, res, json ->
        res.redirect('/reports.html', 301)
    }

    private static GRoute onFatalRoute = { req, res, json ->
        println "OHKO! Fatality. Restarting Server."
        System.exit(1);
    }

    private static Filter addCORSHeaders = { req, res ->
        res.header("Access-Control-Allow-Origin", "*")
        res.header("Access-Control-Allow-Methods", "POST,PUT,DELETE,GET,OPTIONS")
        res.header("Access-Control-Allow-Headers", "Content-Type")
        res.header("Cache-Control", "no-cache, no-store, must-revalidate")
        res.header("Pragma", "no-cache")
        res.header("Expires", "0")
    }
}
