part of pingpong.json.schema;

class PlayerSchema {
  final String id;
  String name;
  bool active;
  bool guest;
  bool frequent;

  PlayerSchema() :
    id = null,
    name = null,
    active = false,
    guest = false,
    frequent = false;

  PlayerSchema.fromJson(json) :
    id = _ObjId_fromJson(json['_id']),
    name = json['name'],
    active = json['active'],
    guest = json['guest'],
    frequent = json['frequent'];

  Map toJson() => {
      '_id': _ObjId_toJson(id),
      'name': name,
      'active': active,
      'guest': guest,
      'frequent': frequent,
  };
}

