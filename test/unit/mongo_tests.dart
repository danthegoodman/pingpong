library pingpong.tests.mongo_tests;

import 'package:unittest/unittest.dart';
import 'package:pingpong/server/util/mongo.dart';

void main() {
  group('Mongo.jsonize', (){
    test('ObjectId', (){
      var value = new ObjectId.fromHexString('123456789012345678901234');
      var result = new MongoProvider().jsonize(value);
      expect(result, equals({':oid': '123456789012345678901234'}));
    });
    test('DateTime', (){
      var value = new DateTime.fromMillisecondsSinceEpoch(1234567890);
      var result = new MongoProvider().jsonize(value);
      expect(result, equals({':date': 1234567890}));
    });
    test('List', (){
      var value = new DateTime.fromMillisecondsSinceEpoch(1234567890);
      var result = new MongoProvider().jsonize([value]);
      expect(result, equals([{':date': 1234567890}]));
    });
    test('Map', (){
      var value = new DateTime.fromMillisecondsSinceEpoch(1234567890);
      var result = new MongoProvider().jsonize({'value':value});
      expect(result, equals({'value': {':date': 1234567890}}));
    });
    test('Combined', (){
      var d1 = new DateTime.fromMillisecondsSinceEpoch(1234567890);
      var d2 = new DateTime.fromMillisecondsSinceEpoch(9876543210);
      var o1 = new ObjectId.fromHexString('123456789012345678901234');
      var o2 = new ObjectId.fromHexString('987654321098765432109876');
      var o3 = new ObjectId.fromHexString('abcdefabcdefabcdefabcdef');

      var value = [{'a':o1},d1,o2,{'b':d2, 'c':o3}];
      var result = new MongoProvider().jsonize(value);
      var expected = [
          {'a': {':oid': '123456789012345678901234'}},
          {':date': 1234567890},
          {':oid': '987654321098765432109876'},
          {'b': {':date':9876543210},'c':{':oid': 'abcdefabcdefabcdefabcdef'}},
      ];
      expect(result, equals(expected));
    });
  });

  group('Mongo.mongoize', () {
    test('ObjectId', (){
      var value = {':oid': '123456789012345678901234'};
      var result = new MongoProvider().mongoize(value);
      expect(result, equals(new ObjectId.fromHexString('123456789012345678901234')));
    });
    test('DateTime', (){
      var value = {':date': 1234567890};
      var result = new MongoProvider().mongoize(value);
      expect(result, equals(new DateTime.fromMillisecondsSinceEpoch(1234567890)));
    });
    test('List', (){
      var value = {':date': 1234567890};
      var result = new MongoProvider().mongoize([value]);
      expect(result, equals([new DateTime.fromMillisecondsSinceEpoch(1234567890)]));
    });
    test('Map', (){
      var value = {':date': 1234567890};
      var result = new MongoProvider().mongoize({'value':value});
      expect(result, equals({'value': new DateTime.fromMillisecondsSinceEpoch(1234567890)}));
    });
    test('Combined', (){
      var d1 = {':date': 1234567890};
      var d2 = {':date':9876543210};
      var o1 = {':oid': '123456789012345678901234'};
      var o2 = {':oid': '987654321098765432109876'};
      var o3 = {':oid': 'abcdefabcdefabcdefabcdef'};

      var value = [{'a':o1},d1,o2,{'b':d2, 'c':o3}];
      var result = new MongoProvider().mongoize(value);
      var expected = [
          {'a': new ObjectId.fromHexString('123456789012345678901234')},
          new DateTime.fromMillisecondsSinceEpoch(1234567890),
          new ObjectId.fromHexString('987654321098765432109876'),
          {'b': new DateTime.fromMillisecondsSinceEpoch(9876543210), 'c':new ObjectId.fromHexString('abcdefabcdefabcdefabcdef')},
      ];
      expect(result, equals(expected));
    });
  });
}
