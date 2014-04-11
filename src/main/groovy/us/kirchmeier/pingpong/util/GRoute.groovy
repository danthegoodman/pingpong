package us.kirchmeier.pingpong.util

import spark.Request
import spark.Response

interface GRoute {
    Object handle(Request request, Response response, Map jsonBody);
}
