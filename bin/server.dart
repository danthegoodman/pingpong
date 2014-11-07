import 'dart:io';
import 'package:stack_trace/stack_trace.dart';
import 'package:pingpong/server/server_main.dart';
import 'package:logging/logging.dart';

const PORT_ENV = 'PINGPONG_PORT';

void main() {
  var port = Platform.environment.containsKey(PORT_ENV) ? int.parse(Platform.environment[PORT_ENV]) : 8000;

  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((evt){
    var sb = new StringBuffer();
    sb.write(evt.message);
    if(evt.error != null){
      sb.write(" ${evt.error}");
    }
    sb.writeln();
    if(evt.stackTrace != null) {
      sb.writeln(new Chain.forTrace(evt.stackTrace));
    }
    if(evt.level == Level.SEVERE){
      stderr.write(sb);
    } else {
      stdout.write(sb);
    }
  });

  startServer(database: 'pingpong2', port: port);
}
