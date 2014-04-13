package us.kirchmeier.pingpong.rest

import org.bson.types.ObjectId
import ratpack.groovy.handling.GroovyChainAction
import ratpack.handling.Context
import us.kirchmeier.pingpong.mongo.GMongoCollection

abstract class ModelRestHandler extends GroovyChainAction {
    @Override
    void execute() throws Exception {
        chain.get ":id", {
            def m = findById(parseId(context))
            if (m == null) {
                context.response.status(404)
                return [:]
            }
            return m
        }

        chain.get {
            return list()
        }

        chain.post {
            def json = parse(Map)
            json.remove('_id')
            return create(json)
        }

        chain.put ":id", {
            def json = parse(Map)
            json['_id'] = parseId(context);
            save(json)
            return json
        }

        chain.delete ":id", {
            deleteById(parseId(context))
            return '{}'
        }
    }

    Serializable parseId(Context context) {
        def strId = context.pathTokens['id']
        try {
            return strId.toInteger();
        } catch (NumberFormatException ignored) {
        }
        return new ObjectId(strId);
    }

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
