library pingpong.scorekeeper;

import 'dart:math' as math;
import 'package:uuid/uuid.dart';
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
    var uuid = window.localStorage.putIfAbsent('clientUuid', () => new Uuid().v4());
    var pendingGame = GameManager.models.firstWhere((it) => it.clientUuid == uuid, orElse: () => null);
    if(pendingGame == null){
      PageManager.goto(new PlayerPage());
    } else {
      var target = pendingGame.isComplete ? new GameOverPage(pendingGame) : new GamePage(pendingGame);
      PageManager.goto(target);
    }
  });
}
