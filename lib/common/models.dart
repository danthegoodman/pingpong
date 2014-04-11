part of pingpong.common;

List _fromJson_List(json)=> json == null ? null : new List.from(json, growable: true);
DateTime _fromJson_DateTime(json)=> json == null ? null : new DateTime.fromMillisecondsSinceEpoch(json['\$date']);
String _fromJSON_ObjectId(json)=> json == null ? null : json['\$oid'];

_toJson_List(List list)=> list;
_toJson_DateTime(DateTime dateValue)=> dateValue == null ? null : {'\$date': dateValue.millisecondsSinceEpoch };
_toJson_ObjectId(String id)=> id == null ? null : {'\$oid': id};

abstract class Model implements Comparable{
  dynamic get id;
  void fromJson(Map json);
  Map toJson();
}

class ModelManager<T extends Model> {
  Function _constructor;
  String _url;
  StreamController _resetStream = new StreamController.broadcast();
  final Map<dynamic, T> _models = {};

  Iterable<T> get models => new List.from(_models.values)..sort();
  Stream get onLoadAll => _resetStream.stream;

  ///Adds a model to the known cache.
  ///
  ///Handy if the data was passed in through another source.
  add(T model) => _models[model.id] = model;

  /// Gets a model, or null if the model cannot be found.
  T get(dynamic id) => _models[id];

  /// Gets all models from their IDs. Will return null for models not yet fetched.
  List<T> mapFrom(Iterable ids) => new List.from(ids.map((id)=> _models[id]));

  /// Gets all models from the server.
  /// Will not execute if data already exists.
  ///
  /// Could be dangerous for large lists.
  Future loadAll(){
    if(_models.isNotEmpty) return new Future.value();

    return getJSON(_url).then((data){
      for(var d in data){
        Model m = _createModel(d);
        _models[m.id] = m;
      }
      _resetStream.add(null);
    });
  }

  /// Gets a model from the server if it hasn't already been fetched.
  Future<T> fetch(dynamic id) {
    T model = _models[id];
    if(model != null){
      return new Future.value(model);
    }

    return getJSON("$_url/$id").then((data){
      T m = _createModel(data);
      _models[id] = m;
      return m;
    });
  }

  /// Saves a new model to the server and caches the result.
  ///
  /// It shouldn't have a id.
  Future<T> create(T model) {
    return _saveOrCreate('POST', _url, model);
  }

  /// Saves an existing model to the server and caches the result.
  Future<T> save(T model){
    return _saveOrCreate('PUT', "$_url/${model.id}", model);
  }

  /// Deletes a model on the server and removes from the cache.
  Future delete(T model){
    return requestJSON('DELETE', "$_url/${model.id}").then((data){
      _models.remove(model.id);
      return null;
    });
  }

  Future<T> _saveOrCreate(String method, String url, T model){
    return requestJSON(method, url, model.toJson()).then((data){
      T m = _createModel(data);
      _models[m.id] = m;
      return m;
    });
  }

  T _createModel(Map data)=> _constructor()..fromJson(data);

}
