package us.kirchmeier.pingpong.util

import com.mongodb.util.JSONSerializers
import ratpack.handling.Context
import ratpack.http.MediaType
import ratpack.render.Renderer

class ExceptionRenderer implements Renderer<Exception> {
    private static def jsonSerilizer = JSONSerializers.strict

    Class<Exception> type = Exception;

    @Override
    void render(Context context, Exception ex) throws Exception {

        ex.printStackTrace()
        context.response.send();
    }
}
