library pingpong.reports;

import 'dart:math' as math;
import 'package:pingpong/common.dart';

part 'all_games.dart';
part 'player_report.dart';
part 'renderer.dart';
part 'settings.dart';

void main(){
  common_main();
  PageManager.add(new AllGamesReport());
  PageManager.add(new PlayerReport());
  PageManager.add(new SettingsPage());

  PlayerManager.loadAll().then((_){
    Player player = _readPlayerFromHash(); //TODO stop this. Its too much once development is done.
    if(player == null){
      PageManager.goto(AllGamesReport);
    } else {
      PageManager.goto(PlayerReport, player);
    }
  });

  querySelector("#settingsLink").onClick.listen((_){
    PageManager.goto(SettingsPage);
  });
}

Player _readPlayerFromHash(){
  var hash = window.location.hash;
  if(hash.isEmpty) return null;
  var playerId = int.parse(hash.substring(1), onError: (_)=> null);
  if(playerId == null) return null;
  return PlayerManager.get(playerId);
}
