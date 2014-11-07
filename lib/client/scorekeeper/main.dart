library pingpong.scorekeeper;

import 'dart:math' as math;
import '../common.dart';
import '../button_handler.dart';
import '../sound_manager.dart';

part 'game_page.dart';
part 'gameover_page.dart';
part 'player_page.dart';
part 'team_page.dart';

math.Random RNG = new math.Random(new DateTime.now().millisecondsSinceEpoch);
SoundManager soundManager = new SoundManager();

void main(){
  common_main();

  Future.wait([PlayerManager.loadAll(), GameManager.loadAll()]).then((q){
    var pendingGames = GameManager.models;
    if(pendingGames.isEmpty){
      PageManager.goto(new PlayerPage());
    } else {
      var game = pendingGames.first;
      var target = game.isComplete ? new GameOverPage(game) : new GamePage(game);
      PageManager.goto(target);
    }
  });
}
