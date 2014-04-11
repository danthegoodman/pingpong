package us.kirchmeier.pingpong.util

import org.slf4j.Logger
import org.slf4j.LoggerFactory
import spark.Request
import spark.Response
import spark.Route


class DartFileRoutes extends Route {
    private static final Logger LOG = LoggerFactory.getLogger(this);

    private List<String> directories = []
    public DartFileRoutes() {
        super('*')

//TODO production?

        def userDir = System.getProperty('user.dir')
        directories << "$userDir/web/"
    }

    @Override
    Object handle(Request request, Response response) {
        def path = request.pathInfo()
        for(def d : directories){
            def f = new File("${d}${path}")
            if(f.exists()){
                setResponseMimeType(response, path)
                return f.text;
            }
        }
        return null;
    }

    def setResponseMimeType(Response response, String path) {
        def ndx = path.lastIndexOf('.')
        if(ndx == -1) return;
        def ext = path.substring(ndx+1);
        def type;
        if(ext == 'html'){
            type = 'text/html';
        } else if(ext == 'dart'){
            type = 'application/dart';
        } else if(ext == 'js'){
            type = 'application/javascript';
        } else {
            println "UNKNOWN EXTENSION = ${ext}"
            type = 'plain/text';
        }

        response.type(type)
    }
}
