library pingpong.server;

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_route/shelf_route.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_proxy/shelf_proxy.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';

import 'common.dart';
import 'util/request_logger.dart';
import 'handlers/rest_handler.dart';
import 'handlers/complete_handler.dart';
import 'handlers/recalculate_handler.dart';

final _LOG = new Logger('server');

Future startServer({String database, int port}) {
  Mongo.init(database);

  var handler = _buildHandler();
  return io.serve(handler, InternetAddress.ANY_IP_V6, port).then((server) {
    _LOG.info('Serving at http://localhost:${server.port}');
    return server;
  });
}

_buildHandler() {
  var chain = [_buildRouter().handler, createStaticHandler('public')];
  if (new Directory('build/web').existsSync()) {
    print("Using the static web handler");
    chain.add(createStaticHandler('build/web'));
  } else {
    print("Using the pub proxy handler");
    var proxyRouter = router()..add('/', ALL_METHODS, proxyHandler('http://localhost:42938'), exactMatch: false);
    chain.add(proxyRouter.handler);
  }

  var cascade = chain.fold(new Cascade(), (c,h)=>c.add(h));
  return cascade.handler;
}

_requestLogger(String msg, bool isError){
  if (isError) {
    _LOG.severe('[ERROR] $msg');
  } else {
    _LOG.info(msg);
  }
}

Router _buildRouter() {
  var r = router(middleware: logHandledRequests(_requestLogger))
    ..get('/', (_) => new Response.movedPermanently('/reports.html'))

    ..post('/api/completeGame', completeHandler, middleware: _dbMiddleware)
    ..get('/ws/recalculate', webSocketHandler(recalculateHandler))

    ..addAll(restHandler('players', _playerValidator), path: '/rest/player', middleware: _dbMiddleware)
    ..addAll(restHandler('activeGames', _gameValidator), path: '/rest/active_game', middleware: _dbMiddleware)
  ;

  REPORTS.forEach((path, handler){
    r.post(path, handler, handlerAdapter: reportsAdapter, middleware: _dbMiddleware);
  });

  return r;
}

_playerValidator(json) => new PlayerSchema.fromJson(json).toJson();
_gameValidator(json) => new GameSchema.fromJson(json).toJson();

Handler _dbMiddleware(Handler handler) =>
  (Request r){
    return Mongo.withConnection((db){
      var req = r.change(context: {'db': db});
      return handler(req);
    });
  };
