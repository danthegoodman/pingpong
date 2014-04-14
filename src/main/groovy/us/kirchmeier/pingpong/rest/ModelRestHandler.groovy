package us.kirchmeier.pingpong.rest

import org.bson.types.ObjectId
import ratpack.groovy.handling.GroovyChainAction
import ratpack.handling.Context
import us.kirchmeier.pingpong.mongo.GMongoCollection

abstract class ModelRestHandler extends GroovyChainAction {
    @Override
    void execute() throws Exception {
        handler(":id") {
            byMethod{
                get { bg context, handleGet }
                put { bg context, handleSave }
                delete { bg context, handleDelete }
            }
        }
        handler {
            byMethod {
                get { bg context, handleList }
                post { bg context, handleCreate }
            }
        }
    }

    /**
     * Run A handler in the background,
     * @param context
     * @param handler
     */
    void bg(Context context, Closure handler) {
        context.background(handler.curry(context)).onError {
            context.render it
        }.then {
            context.render it
        }
    }

    def handleGet = { Context context ->
        return findById(parseId(context)) ?: "not found"
    }

    def handleList = { Context context ->
        return list()
    }

    def handleCreate = { Context context ->
        def json = context.parse(Map)
        json.remove('_id')
        return create(json)
    }

    def handleSave = { Context context ->
        def json = context.parse(Map)
        json['_id'] = parseId(context)
        save(json)
        return json
    }

    def handleDelete = { Context context ->
        deleteById(parseId(context))
        return '{}'
    }

    Serializable parseId(Context context) {
        def strId = context.allPathTokens['id']
        try {
            return strId.toInteger()
        } catch (NumberFormatException ignored) {
        }
        return new ObjectId(strId)
    }

    abstract GMongoCollection getCollection()

    Map findById(def id) {
        collection.findOne(_id: id)?.toMap()
    }

    List<Map> list() {
        return collection.find().toArray(500)*.toMap()
    }

    Map create(Map model) {
        collection.insert(model)
        return model
    }

    void save(Map model) {
        collection.save(model)
    }

    void deleteById(def id) {
        collection.remove(_id: id)
    }
}
