library us.kirchmeier.pingpong.common.models;

import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'ajax.dart';

part 'model/player.dart';
part 'model/game.dart';
part 'model/point.dart';
part 'model/tournament.dart';

List _fromJson_List(json)=> json == null ? null : new List.from(json, growable: true);
DateTime _fromJson_DateTime(json)=> json == null ? null : DateTime.parse(json);

_toJson_List(List list)=> list;
_toJson_DateTime(DateTime date)=> date == null ? null : date.toString();


abstract class Model implements Comparable{
  String get id;
  void fromJson(Map json);
  Map toJson();
}

class ModelManager<T extends Model> {
  Function _constructor;
  String _url;
  StreamController _resetStream = new StreamController.broadcast();
  final Map<String, T> _models = {};

  ModelManager();

  Iterable<T> get models => new List.from(_models.values)..sort();
  Stream get onLoadAll => _resetStream.stream;

  ///Adds a model to the known cache.
  ///
  ///Handy if the data was passed in through another source.
  add(T model) => _models[model.id] = model;

  /// Gets a model, or null if the model cannot be found.
  T get(String id) => _models[id];

  /// Gets all models from their IDs. Will return null for models not yet fetched.
  List<T> mapFrom(Iterable<String> ids) => new List.from(ids.map((id)=> _models[id]));

  /// Gets all models from the server.
  /// Will not execute if data already exists.
  ///
  /// Could be dangerous for large lists.
  Future loadAll(){
    Completer c = new Completer();
    if(_models.isEmpty){
      getJSON(_url).then((data){
        data.forEach((d){
          Model m = _createModel(d);
          _models[m.id] = m;
        });
        c.complete(null);
        _resetStream.add(null);
      });
    } else {
      c.complete(null);
    }

    return c.future;
  }

  /// Gets a model from the server if it hasn't already been fetched.
  Future<T> fetch(String id) {
    Completer<T> c = new Completer<T>();
    T model = _models[id];
    if(model != null){
      c.complete(model);
    } else {
      getJSON("$_url/$id").then((data){
        T m = _createModel(data);
        _models[id] = m;
        c.complete(m);
      });
    }

    return c.future;
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
    Completer c = new Completer();
    requestJSON('DELETE', "$_url/${model.id}").then((data){
      _models.remove(model.id);
      c.complete(null);
    });
    return c.future;
  }

  Future<T> _saveOrCreate(String method, String url, T model){
    Completer<T> c = new Completer<T>();
    requestJSON(method, url, model.toJson()).then((data){
      T m = _createModel(data);
      _models[m.id] = m;
      c.complete(m);
    });
    return c.future;
  }

  T _createModel(Map data)=> _constructor()..fromJson(data);

}