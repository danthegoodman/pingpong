part of pingpong.common;

abstract class Model implements Comparable{
  String get id;
  Map toJson();
}

class ModelManager<T extends Model> {
  final _models = new Map<String,T>();
  final _resetStream = new StreamController.broadcast();

  Function _constructor;
  String _url;

  List<T> get models => new List.from(_models.values)..sort();
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
        Model m = _constructor(d);
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
      T m = _constructor(data);
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
      T m = _constructor(data);
      _models[m.id] = m;
      return m;
    });
  }
}
