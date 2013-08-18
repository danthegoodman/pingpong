library us.kirchmeier.pingpong.scorekeeper;

import 'game_page.dart';
import 'gameover_page.dart';
import 'sc_common.dart';
import 'sound_handler.dart';
import 'player_page.dart';
import 'team_page.dart';
import 'package:pingpong/common.dart';

void main(){
  initSoundManager();
  PageManager.add(new PlayerPage());
  PageManager.add(new TeamPage());
  PageManager.add(new GamePage());
  PageManager.add(new GameOverPage());

  /// I think the page looks better when delayed a bit.
  Future fakeDelay = new Future.delayed(new Duration(milliseconds: 250));

  Future playersLoaded = PlayerManager.loadAll();
  Future gameFetched = getJSON('/inprogress').then((Map data){
    if(data['game'] != null){
      GAME = new Game()..fromJson(data['game']);
      GameManager.add(GAME);
    }
    if(data['tournament'] != null){
      TOURNAMENT = new Tournament()..fromJson(data['tournament']);
      TournamentManager.add(TOURNAMENT);
    }
  });

  Future.wait([fakeDelay, playersLoaded, gameFetched]).then((q){
    var target;
    if(GAME == null){
      target = PlayerPage;
    } else {
      target = GAME.isComplete ? GameOverPage : GamePage;
    }
    PageManager.goto(target);
  });
}
