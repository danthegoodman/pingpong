library pingpong.tests.rolling_average;

import 'package:unittest/unittest.dart';
import 'package:pingpong/common/functions.dart';

//This compensates for minor double rounding errors.
const SMALL_DELTA = 1e-7;

void main() {
  group('serverIndex', (){
    test('singles - before deuce', (){
      var a = [0,1,2,3,4,10,11,12,13,14,20,21,22,23,24,30,31,32,33,34];
      var b = [5,6,7,8,9,15,16,17,18,19,25,26,27,28,29,35,36,37,38,39];
      for (var i in a) expect(serverIndex(i, 2), equals(0));
      for (var i in b) expect(serverIndex(i, 2), equals(1));
    });
    test('doubles - before deuce', (){
      var a = [0,1,2,3,4,20,21,22,23,24];
      var b = [5,6,7,8,9,25,26,27,28,29];
      var c = [10,11,12,13,14,30,31,32,33,34];
      var d = [15,16,17,18,19,35,36,37,38,39];
      for (var i in a) expect(serverIndex(i, 4), equals(0));
      for (var i in b) expect(serverIndex(i, 4), equals(1));
      for (var i in c) expect(serverIndex(i, 4), equals(2));
      for (var i in d) expect(serverIndex(i, 4), equals(3));
    });
    test('singles - after deuce', (){
      var a = [40, 42, 44, 46, 48, 50];
      var b = [41, 43, 45, 47, 49, 51];
      for (var i in a) expect(serverIndex(i, 2), equals(0));
      for (var i in b) expect(serverIndex(i, 2), equals(1));
    });
    test('doubles - after deuce', (){
      var a = [40, 44, 48];
      var b = [41, 45, 49];
      var c = [42, 46, 50];
      var d = [43, 47, 51];
      for (var i in a) expect(serverIndex(i, 4), equals(0));
      for (var i in b) expect(serverIndex(i, 4), equals(1));
      for (var i in c) expect(serverIndex(i, 4), equals(2));
      for (var i in d) expect(serverIndex(i, 4), equals(3));
    });
  });

  group('rollingAverage', () {
    test('average calculation', () {
      expect(rollingAverage([5,5,5,5,5], 5), closeTo(5.0, SMALL_DELTA));
      expect(rollingAverage([5,5,5,5,2], 5), closeTo(4.8, SMALL_DELTA));
      expect(rollingAverage([5,5,5,2,5], 5), closeTo(4.6, SMALL_DELTA));
      expect(rollingAverage([5,5,2,5,5], 5), closeTo(4.4, SMALL_DELTA));
      expect(rollingAverage([5,2,5,5,5], 5), closeTo(4.2, SMALL_DELTA));
      expect(rollingAverage([2,5,5,5,5], 5), closeTo(4.0, SMALL_DELTA));
    });
    test('accept short input', () {
      expect(rollingAverage([5,5,5], 5), closeTo(5.00, SMALL_DELTA));
      expect(rollingAverage([5,5,2], 5), closeTo(4.25, SMALL_DELTA));
      expect(rollingAverage([5,2,5], 5), closeTo(4.00, SMALL_DELTA));
      expect(rollingAverage([2,5,5], 5), closeTo(3.75, SMALL_DELTA));
    });
    test('ignore long input', () {
      expect(rollingAverage([5,5,5,5,5,0,0], 5), closeTo(5.0, SMALL_DELTA));
      expect(rollingAverage([5,5,5,5,2,0,0], 5), closeTo(4.8, SMALL_DELTA));
      expect(rollingAverage([5,5,5,2,5,0,0], 5), closeTo(4.6, SMALL_DELTA));
      expect(rollingAverage([5,5,2,5,5,0,0], 5), closeTo(4.4, SMALL_DELTA));
      expect(rollingAverage([5,2,5,5,5,0,0], 5), closeTo(4.2, SMALL_DELTA));
      expect(rollingAverage([2,5,5,5,5,0,0], 5), closeTo(4.0, SMALL_DELTA));
    });
    test('empty input', () {
      expect(rollingAverage([], 5), isNull);
    });
  });
}
