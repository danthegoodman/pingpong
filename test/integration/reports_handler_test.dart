library pingpong.tests.ideal_team;

import 'package:unittest/unittest.dart';
import '../util/http_util.dart';

//This compensates for minor double rounding errors.
const SMALL_DELTA = 1e-7;

const P1 = '000000000000000000000001';
const P2 = '000000000000000000000002';
const P3 = '000000000000000000000003';
const P4 = '000000000000000000000004';

void main() {
  _idealTeamTests();
  _bestGamesTests();
  _playerTotalsTests();
}

_idealTeamTests() {
  group('/report/idealTeam ->', () {
    test('view report for four players', () {
      return http('post', "/report/idealTeam", {'players': [P1, P2, P3, P4]}).then((res) {
        expect(res.json, isMap);
        Map json = res.json;
        expect(json.length, 3);

        var sum = 0;
        sum += ((29 / 17) - 1) * (150 / 150);
        sum += ((11 / 17) - 1) * (149 / 150);
        sum += ((19 / 17) - 1) * (148 / 150);
        var count = (150 / 150) + (149 / 150) + (148 / 150);
        expect(json["$P1,$P3-$P2,$P4"]['games'], 3);
        expect(json["$P1,$P3-$P2,$P4"]['score'], sum / count);

        sum = 0;
        sum += ((15 / 17) - 1) * (150 / 150);
        sum += ((14 / 17) - 1) * (149 / 150);
        count = (150 / 150) + (149 / 150);
        expect(json["$P1,$P2-$P3,$P4"]['games'], 2);
        expect(json["$P1,$P2-$P3,$P4"]['score'], sum / count);
        expect(json["$P1,$P4-$P2,$P3"]['games'], 0);
        expect(json["$P1,$P4-$P2,$P3"]['score'], isNull);
      });
    });

    test('view report for two players', () {
      return http('post', "/report/idealTeam", {'players': [P1, P2]}).then((res) {
        expect(res.json, isMap);
        Map json = res.json;
        expect(json.length, 1);

        var sum = 0;
        sum += ((25 / 17) - 1) * (150 / 150);
        sum += ((20 / 17) - 1) * (149 / 150);
        sum += ((18 / 17) - 1) * (148 / 150);
        var count = (150 / 150) + (149 / 150) + (148 / 150);
        expect(json["$P1-$P2"]['games'], 3);
        expect(json["$P1-$P2"]['score'], closeTo(sum / count, SMALL_DELTA));
      });
    });
  });
}

_bestGamesTests() {
  group('/report/bestGames ->', () {
    test('get report', () {
      return http('post', "/report/bestGames", {}).then((res) {
        expect(res.json, isMap);
        Map json = res.json;
        expect(json.length, 4);

        _verifyGame(json['highestScore'], [P3, P4, P1, P2], 29, 31);
        _verifyGame(json['lowestScore'], [P2, P1, P4, P3], 21, 11);
        _verifyGame(json['doublesLongestStreak'], [P1, P2, P3, P4], 21, 19);
        _verifyGame(json['singlesLongestStreak'], [P1, P2], 27, 25);
      });
    });
  });
}

_playerTotalsTests(){
  group('/report/playerTotals ->', () {
    test('get report', () {
      return http('post', "/report/playerTotals", [P1,P2,P3,P4]).then((res) {
        expect(res.json, isList);
        List json = res.json;
        expect(json.length, 4);

        var players = new Map.fromIterable(json, key: (x)=> x['_id']);
        _verifyPlayerTotals(players[P1], goodServes:119, badServes:3, fatalServes:1, doublesWins: 2, doublesLosses:3, singlesWins: 1, singlesLosses: 2);
        _verifyPlayerTotals(players[P2], goodServes:113, badServes:4, fatalServes:1, doublesWins: 3, doublesLosses:2, singlesWins: 2, singlesLosses: 1);
        _verifyPlayerTotals(players[P3], goodServes:47, badServes:3, fatalServes:0, doublesWins: 2, doublesLosses:3, singlesWins: 0, singlesLosses: 0);
        _verifyPlayerTotals(players[P4], goodServes:47, badServes:0, fatalServes:0, doublesWins: 3, doublesLosses:2, singlesWins: 0, singlesLosses: 0);
      });
    });
  });
}

_verifyGame(Map json, List players, int score0, int score1){
  var l = players.map((p)=> {':oid': p}).toList();
  expect(json['players'], equals(l));
  expect(json['points'].where((x)=> x.abs() == 1).length, equals(score0));
  expect(json['points'].where((x)=> x.abs() == 2).length, equals(score1));
}

_verifyPlayerTotals(Map data, {goodServes, badServes, fatalServes, doublesWins, doublesLosses, singlesWins, singlesLosses}){
//  expect(data['badServes'], equals(badServes));
  expect(data['goodServes'], equals(goodServes));
  expect(data['fatalServes'], equals(fatalServes));
  expect(data['doublesWins'], equals(doublesWins));
  expect(data['doublesLosses'], equals(doublesLosses));
  expect(data['singlesWins'], equals(singlesWins));
  expect(data['singlesLosses'], equals(singlesLosses));
}
