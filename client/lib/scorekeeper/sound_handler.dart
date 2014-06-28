library us.kirchmeier.pingpong.scorekeeper.sound_handler;

import 'sc_common.dart';
import 'package:js/js.dart' as js;

initSoundManager(){
  js.context['soundManager'].onready(_onSoundManagerReady);
}

_onSoundManagerReady(q){
  onScoreChange.listen(_onScoreChange);

  _initSound('score');
  _initSound('undo', volume: 30);
  _initSound('badServe');
  _initSound('sadTrombone');
}

_onScoreChange(ScoreChange sc){
  String sound = '';
  if(sc.isPoint){
    sound = 'score';
  } else if(sc.isUndo){
    sound = 'undo';
  } else if(sc.isBadServe){
    if(GAME.isComplete){
      sound = 'sadTrombone';
    } else {
      sound = 'badServe';
    }
  }

  if(sound.isEmpty) return;
  js.context['soundManager'].play(sound);
}

_initSound(String id, {volume: 100}){
  var ops = {
      'id':id,
      'url': "sound/${id}.mp3",
      'autoLoad': true,
      'volume': volume};
  js.context['soundManager'].createSound(js.map(ops));
}
