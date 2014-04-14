package us.kirchmeier.pingpong.rest

import org.bson.types.ObjectId
import ratpack.groovy.handling.GroovyChainAction
import ratpack.handling.Context
import us.kirchmeier.pingpong.mongo.GMongoCollection

import java.util.concurrent.Callable

abstract class ModelRestHandler extends GroovyChainAction {
    @Override
    void execute() throws Exception {
        chain.get ":id", {
            bg(context) {
                findById(parseId(context)) ?: "not found"
            }
        }

        chain.get {
            bg(context) {
                list()
            }
        }

        chain.post {
            def json = parse(Map)
            json.remove('_id')
            bg(context){
                create(json)
            }
        }

        chain.put ":id", {
            def json = parse(Map)
            json['_id'] = parseId(context);
            bg(context){
                save(json)
                return json
            }
        }

        chain.delete ":id", {
            bg(context){
                deleteById(parseId(context))
                return '{}'
            }
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

    void bg(Context context, Callable closure){
        context.background(closure).onError {
            context.render it
        }.then {
            context.render it
        }
    }
}
