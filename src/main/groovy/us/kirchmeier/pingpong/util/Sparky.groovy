package us.kirchmeier.pingpong.util

import com.mongodb.util.JSON
import com.mongodb.util.JSONSerializers
import spark.Request
import spark.Response
import spark.Route
import spark.Spark
import us.kirchmeier.pingpong.Server

//I really don't like having to specify paths in routes.
//Plus, all calls use json.
class Sparky {
    private static def jsonSerilizer = JSONSerializers.strict

    static void get(String path, GRoute route) {
        Spark.get(asRoute(path, route))
    }

    static void post(String path, GRoute route) {
        Spark.post(asRoute(path, route))
    }

    static void put(String path, GRoute route) {
        Spark.put(asRoute(path, route))
    }

    static void delete(String path, GRoute route) {
        Spark.delete(asRoute(path, route))
    }

    private static Route asRoute(String path, GRoute route) {
        new Route(path) {
            @Override
            Object handle(Request request, Response response) {
                def body = request.body()
                Map json = [:]
                if (body) {
                    json = JSON.parse(body).toMap() as Map
                }
                if(!Server.isProduction){
                    println "${request.requestMethod()} ${request.pathInfo()}"
                    if(body){ println "    ${body}"}
                }

                return route.handle(request, response, json)
            }

            @Override
            String render(Object element) {
                if(element == null) return null;
                if(element == String) return element;
                jsonSerilizer.serialize(element);
            }
        }
    }

}
