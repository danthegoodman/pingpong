package us.kirchmeier.pingpong.util

import com.mongodb.util.JSONSerializers
import ratpack.handling.Context
import ratpack.http.MediaType
import ratpack.render.Renderer

class JsonMapRenderer implements Renderer<Map> {
    private static def jsonSerilizer = JSONSerializers.strict

    Class<Map> type = Map;

    @Override
    void render(Context context, Map map) throws Exception {
        context.response.send(MediaType.APPLICATION_JSON, jsonSerilizer.serialize(map));
    }
}
