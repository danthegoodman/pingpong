package us.kirchmeier.pingpong.util

import com.mongodb.util.JSON
import ratpack.handling.Context
import ratpack.http.MediaType
import ratpack.http.TypedData
import ratpack.parse.NoOptParserSupport


class JsonParser extends NoOptParserSupport{
    public JsonParser() {
        super(MediaType.APPLICATION_JSON)
    }

    @Override
    protected <T> T parse(Context context, TypedData requestBody, Class<T> type) throws Exception {
        if (type.equals(Map.class)) {
            return JSON.parse(new String(requestBody.bytes)).toMap()
        }

        return null;
    }
}
