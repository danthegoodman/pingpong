package us.kirchmeier.pingpong.rest

import org.bson.types.ObjectId
import spark.Request
import us.kirchmeier.pingpong.mongo.GMongoCollection
import us.kirchmeier.pingpong.util.Sparky

abstract class ModelRestRouter {
    void install() {
        Sparky.get "/rest/$path/:id", { req, res, json ->
            def m = findById(parseId(req))
            if (m == null) {
                res.status(404)
                return [:]
            }
            return m
        }

        Sparky.get "/rest/$path", { req, res, json ->
            return list()
        }

        Sparky.post "/rest/$path", { req, res, json ->
            json.remove('_id')
            return create(json)
        }

        Sparky.put "/rest/$path/:id", { req, res, json ->
            json['_id'] = parseId(req);
            save(json)
            return json
        }

        Sparky.delete "/rest/$path/:id", { req, res, json ->
            deleteById(parseId(req))
            return '{}'
        }
    }

    Serializable parseId(Request req) {
        def strId = req.params(':id');
        try {
            return strId.toInteger();
        } catch (NumberFormatException ignored) {
        }
        return new ObjectId(strId);
    }

    abstract String getPath()
    abstract GMongoCollection getCollection()

    Map findById(def id) {
        collection.findOne(_id: id)?.toMap()
    }

    List<Map> list() {
        return collection.find().toArray(500)*.toMap()
    }

    Map create(Map model) {
        collection.insert(model);
        return model;
    }

    void save(Map model) {
        collection.save(model)
    }

    void deleteById(def id) {
        collection.remove(_id: id)
    }
}
