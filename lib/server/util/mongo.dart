library pingpong.server.mongo;

import 'dart:async';
import 'dart:collection';

import 'package:connection_pool/connection_pool.dart';
import 'package:mongo_dart/mongo_dart.dart';

export 'package:mongo_dart/mongo_dart.dart';

final MongoProvider Mongo = new MongoProvider();
typedef MongoCallback(DbCollection collection);

class MongoProvider {
  MongoDbPool pool;

  init(String database) {
    pool = new MongoDbPool('mongodb://localhost/${database}', 10);
  }

  Future withConnection(callback(Db connection)) {
    ManagedConnection mc;
    return pool.getConnection()
    .then((c) {
      mc = c;
      return callback(c.conn);
    }).catchError((e) {
      pool.releaseConnection(mc, markAsInvalid: true);
      throw e;
    }, test: (e) => e is ConnectionException)
    .then((x) {
      pool.releaseConnection(mc);
      return x;
    });
  }

  Future withCollection(String collection, MongoCallback callback) => withConnection((mc) => callback(mc.collection(collection)));

  Future withPlayers(MongoCallback callback) => withCollection('players', callback);
  Future withActiveGames(MongoCallback callback) => withCollection('activeGames', callback);
  Future withGames(MongoCallback callback) => withCollection('games', callback);

  /// Converts data from dart types to json.
  jsonize(dynamic v) {
    if(v is ObjectId) return {':oid':v.toHexString()};
    if(v is DateTime) return {':date':v.millisecondsSinceEpoch};
    if(v is Iterable) return v.map(jsonize).toList();
    if(v is Map) return new Map.fromIterables(v.keys, v.values.map(jsonize));
    return v;
  }

  /// Converts data from json to dart and bson types
  mongoize(v) {
    if(v is Iterable) return v.map(mongoize).toList();
    if(v is Map){
      if(v.length == 1){
        if(v.containsKey(':oid')) return new ObjectId.fromHexString(v[':oid']);
        if(v.containsKey(':date')) return new DateTime.fromMillisecondsSinceEpoch(v[':date']);
      }
      return new Map.fromIterables(v.keys, v.values.map(mongoize));
    }
    return v;
  }
}

class MongoDbPool extends ConnectionPool<Db> {
  final _openConnections = new HashSet<Db>();
  final String uri;

  MongoDbPool(this.uri, int poolSize) : super(poolSize, shareableConnections: false);

  @override
  void closeConnection(Db conn) {
    conn.close();
    _openConnections.remove(conn);
  }

  @override
  Future<Db> openNewConnection() {
    var conn = new Db(uri);
    return conn.open().then((_) {
      _openConnections.add(conn);
      return conn;
    });
  }

  Future close() {
    return Future.wait(_openConnections.map((db) => db.close()));
  }
}
