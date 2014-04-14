package us.kirchmeier.pingpong.util

import ratpack.handling.Context
import ratpack.render.Renderer

@javax.inject.Singleton
class ExceptionRenderer implements Renderer<Exception> {
    Class<Exception> type = Exception

    @Override
    void render(Context context, Exception ex) throws Exception {
        def writer = new StringWriter()
        ex.printStackTrace(new PrintWriter(writer))
        context.response.send(writer.toString())
    }
}
