library pingpong.client.sound_manager;

import 'dart:js';

class SoundManager {
  SoundManager() {
    _soundManager.callMethod('onready', [new JsFunction.withThis(_onSoundManagerReady)]);
  }

  void score() => _play('score');
  void undo() => _play('undo');
  void badServe() => _play('badServe');
  void sadTrombone() => _play('sadTrombone');

  void _play(String name){
    _soundManager.callMethod('play', [name]);
  }
}

_onSoundManagerReady(_, x){
  _initSound('score');
  _initSound('undo', volume: 30);
  _initSound('badServe');
  _initSound('sadTrombone');
}

_initSound(String id, {volume: 100}){
  var ops = {
      'id':id,
      'url': "sound/${id}.mp3",
      'autoLoad': true,
      'volume': volume};
  _soundManager.callMethod('createSound', [new JsObject.jsify(ops)]);
}

JsObject get _soundManager => context['soundManager'];
