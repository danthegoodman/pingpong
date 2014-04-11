package us.kirchmeier.pingpong.mongo

import com.mongodb.*
import org.bson.types.ObjectId

class GMongoCollection {
    DBCollection col

    GMongoCollection(DBCollection col) {
        this.col = col;
    }

    DBObject findOne(Map query = [:]) {
        return col.findOne(new BasicDBObject(query))
    }

    @Override
    DBCursor find() {
        return col.find()
    }

    DBCursor find(Map query) {
        return col.find(new BasicDBObject(query))
    }

    DBCursor find(Map query, Map keys) {
        return col.find(new BasicDBObject(query), new BasicDBObject(keys))
    }

    /**
     * If an '_id' fields doesn't exist, it will be added into the map before inserting.
     */
    WriteResult insert(Map obj) {
        if(obj['_id'] == null){
            obj['_id'] = new ObjectId();
        }
        col.insert(new BasicDBObject(obj))
    }

    WriteResult insert(List<Map> objs) {
        col.insert(objs.collect { new BasicDBObject(it) })
    }

    WriteResult save(Map obj) {
        return col.save(new BasicDBObject(obj));
    }

    WriteResult remove(Map query) {
        return col.remove(new BasicDBObject(query));
    }

    WriteResult update(Map query, Map update, Map options = [:]) {
        return col.update(new BasicDBObject(query), new BasicDBObject(update), options.upsert as boolean, options.multi as boolean);
    }

    DBObject findAndModify(Map query, Map update) {
        return col.findAndModify(new BasicDBObject(query), new BasicDBObject(update))
    }

    def aggregate(List<Map> pipeline) {
        def items = pipeline.collect{ new BasicDBObject(it) }
        def a = items.first()
        def x = items.drop(1) as BasicDBObject[]
        col.aggregate(a, x)
    }

    def aggregate(Map... pipeline) {
        aggregate(pipeline.toList())
    }
}
