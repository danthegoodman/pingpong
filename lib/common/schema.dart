library pingpong.json.schema;

part 'schema/game_schema.dart';
part 'schema/player_schema.dart';

_ObjId_fromJson(Map data) => data == null ? null : data[':oid'];
_ObjId_toJson(String data) => data == null ? null : {':oid': data};

_Date_fromJson(Map data) => data == null ? null : new DateTime.fromMillisecondsSinceEpoch(data[':date'], isUtc: false);
_Date_toJson(DateTime data) => data == null ? null : {':date': data.millisecondsSinceEpoch};

_identity(x) => x;
_List_fromJson(Iterable data, [mapper(x) = _identity]) => data == null ? null : new List.from(data.map(mapper), growable:true);
_List_toJson(List data, [mapper(x) = _identity]) => data == null ? null : data.map(mapper).toList();
