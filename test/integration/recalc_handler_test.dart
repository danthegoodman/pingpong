library pingpong.tests.recalculate;

import 'dart:io';
import 'package:unittest/unittest.dart';
import '../util/http_util.dart';

void main() {
  group('/ws/recalculate ->', () {
    test('updates reports without error', () {
      return WebSocket.connect("ws://localhost:${TESTING_PORT}/ws/recalculate")
        .then((ws)=> ws.toList()).then((List msgs){
          expect(msgs[0], equals("Beginning Report Recalculation"));
          expect(msgs[1], matches(r'Fetched \d+ games'));
          expect(msgs[2], matches(r'Fetched \d+ players'));
          expect(msgs[3], equals('Dropped 0 collections'));
          msgs.getRange(4, msgs.length-1).forEach((m){
            expect(m, equals('Updated a report'));
          });
          expect(msgs.last, equals("Finished"));
      });
    });
  });
}
