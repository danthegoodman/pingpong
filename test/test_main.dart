library pingpong.tests;

import 'dart:io';
import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
import 'package:pingpong/server/server_main.dart';
import 'package:pingpong/server/util/mongo.dart';
import 'integration/setup_data.dart';

import 'unit/function_tests.dart' as function_test;
import 'unit/game_schema_tests.dart' as game_schema_tests;
import 'unit/mongo_tests.dart' as mongo_tests;
import 'integration/recalc_handler_test.dart' as recalc_handler_test;
import 'integration/rest_handler_test.dart' as rest_handler_test;
import 'integration/reports_handler_test.dart' as reports_handler_test;

HttpServer server;

void main() {
  Logger.root.level = Level.WARNING;
  Logger.root.onRecord.listen((evt){
    var m = evt.message;
    if(evt.error != null) m = "$m :: ${evt.error}";
    if(evt.stackTrace != null) m = "$m\n${evt.stackTrace}";
    logMessage(m);
  });

  setUp(()=> server == null ? _init() : null);
  tearDown(()=> identical(currentTestCase, testCases.last) ? _shutdown() : null);

  function_test.main();
  game_schema_tests.main();
  mongo_tests.main();
  recalc_handler_test.main();
  rest_handler_test.main();
  reports_handler_test.main();
}

_init() {
  return startServer(database: 'pingpong_test', port: 9900)
    .then((s) => server = s)
    .then((_) => _resetMongoDatabase());
}

_shutdown(){
  return server.close()
    .then((_)=> Mongo.pool.close());
}

_resetMongoDatabase() {
  return Mongo.pool.getConnection().then((c) {
    var db = c.conn;
    return db.drop()
      .then((_)=> setUpIntegrationData(db))
      .then((_)=> Mongo.pool.releaseConnection(c));
  });
}


