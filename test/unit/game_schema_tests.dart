library pingpong.tests.game_schema;

import 'package:unittest/unittest.dart';
import 'package:pingpong/common/schema.dart';

void main() {
  group('GameSchema.longestPointStreak', (){
    test('normal', () {
      var gs = new GameSchema()..points = [1,1,1,1,2,2];
      var s = gs.longestPointStreak;
      expect(s.length, equals(4));
      expect(s.team, equals(0));
    });
    test('with bad serves', () {
      var gs = new GameSchema()..points = [-2,2,-1,1,1,-1];
      var s = gs.longestPointStreak;
      expect(s.length, equals(4));
      expect(s.team, equals(0));
    });
    test('tie takes first longest',(){
      var gs = new GameSchema()..points = [2,2,-2,2,1,1,1,-1];
      var s = gs.longestPointStreak;
      expect(s.length, equals(4));
      expect(s.team, equals(1));
    });
    test('small streaks',(){
      var gs = new GameSchema()..points = [1,2,1,2,1,2,1,2,1,2];
      var s = gs.longestPointStreak;
      expect(s.length, equals(1));
      expect(s.team, equals(0));
    });
    test('long streaks',(){
      var gs = new GameSchema()..points = [1,2,2,1,1,1,2,2,2,2,1,1,1,1,1,2,2,2,2,2,2];
      var s = gs.longestPointStreak;
      expect(s.length, equals(6));
      expect(s.team, equals(1));
    });
  });
}
