library pingpong.server.rest_handler;

import 'package:shelf_route/shelf_route.dart';
import '../common.dart';

typedef dynamic SchemaValidator(json);

RouteableFunction restHandler(String name, SchemaValidator validator) {
  handleList(Request r, DbCollection c) {
    var cursor = c.find()..limit = 100;
    return cursor.toList();
  }

  handleGet(Request r, DbCollection c) {
    return c.findOne({'_id': _getIdParam(r)});
  }

  handleCreate(Request r, DbCollection c) {
    return r.readAsString().then((content){
      var data = JSON.decode(content);
      data = validator(data);
      data['_id'] = new ObjectId();
      return c.insert(Mongo.mongoize(data)).then((_)=> data);
    });
  }

  handleSave(Request r, DbCollection c) {
    return r.readAsString().then((content) {
      var data = JSON.decode(content);
      data = validator(data);
      data['_id'] = _getIdParam(r);
      return c.save(Mongo.mongoize(data)).then((_)=> data);
    });
  }

  handleDelete(Request r, DbCollection c) {
    return c.remove({'_id': _getIdParam(r)}).then((_)=> {});
  }

  Handler restAdapter(Function f) =>
      (Request req) {
        Db db = req.context['db'];
        return f(req, db.collection(name)).then(_translateRestResponse);
      };

  return (Router r) {
    r
      ..get('/', handleList, handlerAdapter: restAdapter)
      ..post('/', handleCreate, handlerAdapter: restAdapter)
      ..get('/{id}', handleGet, handlerAdapter: restAdapter)
      ..put('/{id}', handleSave, handlerAdapter: restAdapter)
      ..delete('/{id}', handleDelete, handlerAdapter: restAdapter);
  };
}

_translateRestResponse(val){
  var content = val == null ? '' : JSON.encode(Mongo.jsonize(val));
  return new Response.ok(content, headers: JSON_HEADERS);
}

_getIdParam(Request r){
  var id = getPathParameter(r, 'id');
  return new ObjectId.fromHexString(id);
}

