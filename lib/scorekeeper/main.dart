library pingpong.scorekeeper;

import 'dart:math' as math;
import 'package:pingpong/common.dart';
import 'package:pingpong/button_handler.dart';
import 'package:pingpong/sound_manager.dart';

part 'game_page.dart';
part 'gameover_page.dart';
part 'player_page.dart';
part 'team_page.dart';

math.Random RNG = new math.Random(new DateTime.now().millisecondsSinceEpoch);
SoundManager soundManager = new SoundManager();

void main(){
  common_main();
  PageManager.add(new PlayerPage());
  PageManager.add(new TeamPage());
  PageManager.add(new GamePage());
  PageManager.add(new GameOverPage());

  /// I think the page looks better when delayed a bit.
  Future fakeDelay = new Future.delayed(new Duration(milliseconds: 250));

  Future.wait([fakeDelay, PlayerManager.loadAll(), GameManager.loadAll()]).then((q){
    var pendingGames = GameManager.models;
    if(pendingGames.isEmpty){
      PageManager.goto(PlayerPage);
    } else {
      var game = pendingGames.first;
      var target = game.isComplete ? GameOverPage : GamePage;
      PageManager.goto(target, game);
    }
  });
}
