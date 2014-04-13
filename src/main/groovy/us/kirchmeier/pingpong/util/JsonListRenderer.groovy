package us.kirchmeier.pingpong.util

import com.mongodb.util.JSONSerializers
import ratpack.handling.Context
import ratpack.http.MediaType
import ratpack.render.Renderer

class JsonListRenderer implements Renderer<List> {
    private static def jsonSerilizer = JSONSerializers.strict

    Class<List> type = List;

    @Override
    void render(Context context, List list) throws Exception {
        context.response.send(MediaType.APPLICATION_JSON, jsonSerilizer.serialize(list));
    }
}
