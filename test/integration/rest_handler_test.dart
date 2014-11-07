library pingpong.tests.rest;

import 'package:unittest/unittest.dart';
import '../util/http_util.dart';

void main() {
  Map newPlayer;
  String newPlayerId;

  group('/rest/player ->', () {
    test('GET : list all players', () {
      return http('get', "/rest/player").then((res) {
        expect(res.json, isList);
        expect(res.json.length, 6);
      });
    });

    test('POST : creates new players, ignores bad fields', () {
      var body = {'name': 'Omega', 'guest': false, 'active': true, 'frequent': false, 'blah': 1};
      return http('post', "/rest/player", body).then((res){
        var json = res.json;
        expect(json, isMap);
        expect(json.length, equals(5));
        expect(json['_id'], isMap);
        expect(json['_id'][':oid'], new isInstanceOf<String>());
        expect(json['_id'][':oid'].length, 24);
        expect(json['name'], equals('Omega'));
        expect(json['guest'], equals(false));
        expect(json['active'], equals(true));
        expect(json['frequent'], equals(false));
        expect(json.containsKey('blah'), isFalse);
        newPlayer = json;
        newPlayerId = json['_id'][':oid'];
      });
    });

    test('GET : contains new player', () {
      return http('get', "/rest/player").then((res) {
        expect(res.json, isList);
        expect(res.json.length, 7);
        expect(res.json, contains(equals(newPlayer)));
      });
    });

    test('GET /{id} : gets new player', () {
      return http('get', "/rest/player/${newPlayerId}").then((res) {
        expect(res.json, equals(newPlayer));
      });
    });

    test('PUT /{id} : updates new player, ignores bad fields', () {
      var body = {'name': 'Omega', 'guest': false, 'active': false, 'frequent': false, 'blah': 1};
      return http('put', "/rest/player/${newPlayerId}", body).then((res) {
        newPlayer['active'] = false;
        expect(res.json, equals(newPlayer));
      });
    });

    test('GET /{id} : gets new player with changes', () {
      return http('get', "/rest/player/${newPlayerId}").then((res) {
        expect(res.json, equals(newPlayer));
      });
    });

    test('DELETE /{id} : delete new player', () {
      return http('delete', "/rest/player/${newPlayerId}").then((res) {
        expect(res.statusCode, equals(200));
      });
    });

    test('GET /{id} : gets new player is missing', () {
      return http('get', "/rest/player/${newPlayerId}").then((res) {
        expect(res.statusCode, equals(200));
        expect(res.json, isNull);
      });
    });

  });
}
