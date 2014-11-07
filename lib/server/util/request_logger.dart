library pingpong.server.request_logger;

import 'dart:async';
import 'package:shelf/shelf.dart';
import 'package:stack_trace/stack_trace.dart';

///modified version of the shelf request logger, skips 404 requests
Middleware logHandledRequests(Function logger) => (innerHandler) {
  return (request) {
    var startTime = new DateTime.now();
    var watch = new Stopwatch()..start();

    return new Future.sync(() => innerHandler(request)).then((response) {
      if(response.statusCode == 404) return response;
      var msg = _getMessage(startTime, response.statusCode, request.url, request.method, watch.elapsed);
      logger(msg, false);
      return response;
    }, onError: (error, stackTrace) {
      if (error is HijackException) throw error;

      var msg = _getErrorMessage(startTime, request.url, request.method,
      watch.elapsed, error, stackTrace);
      logger(msg, true);
      throw error;
    });
  };
};

String _getMessage(DateTime requestTime, int statusCode, Uri url,
                   String method, Duration elapsedTime) {
  if(statusCode != 200){
    return '${requestTime}\t$elapsedTime\t$method\t[${statusCode}]\t${url}';
  } else {
    return '${requestTime}\t$elapsedTime\t$method\t${url}';
  }
}

String _getErrorMessage(DateTime requestTime, Uri url,
                        String method, Duration elapsedTime, Object error, StackTrace stack) {

  var chain = new Chain.current();
  if (stack != null) {
    chain = new Chain.forTrace(stack)
    .foldFrames((frame) => frame.isCore || frame.package == 'shelf')
    .terse;
  }

  var msg = '${requestTime}\t$elapsedTime\t$method\t${url}\n$error';
  if(chain == null) return msg;

  return '$msg\n$chain';
}
