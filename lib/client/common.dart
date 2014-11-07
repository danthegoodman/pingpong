library pingpong.common;

import 'dart:html';
import 'dart:async';
import 'dart:convert';

import '../common/schema.dart';
import '../common/functions.dart';

export 'dart:html' hide Player, Point;
export 'dart:async';

part 'common/ajax.dart';
part 'common/page_manager.dart';
part 'common/models.dart';
part 'common/widgets.dart';
part 'common/player.dart';
part 'common/game.dart';

common_main(){
  document.body.children
    ..insert(0, new DivElement()..id = 'bgimg')
    ..insert(1, new DivElement()..id = 'fadeOutMask')
    ..insert(2, new DivElement()..id = 'asyncError'
                                ..hidden = true
                                ..title='Server Error. Check Console.');
}

const Team T0 = const Team._(0);
const Team T1 = const Team._(1);

class Team {
  final int index;
  const Team._(this.index);
  factory Team(int idx) => idx == 0 ? T0 : T1;

  Team get other => index == 0 ? T1 : T0;
}
