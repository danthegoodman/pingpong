library pingpong.client.sound_manager;

import 'dart:js';

class SoundManager {
  SoundManager() {
    _soundManager.callMethod('onready', [new JsFunction.withThis(_onSoundManagerReady)]);
  }

  void scoreLeft() => _play('score', pan: -100);
  void scoreRight() => _play('score', pan: 100);
  void undo() => _play('undo');
  void badServe() => _play('badServe');
  void sadTrombone() => _play('sadTrombone');

  void _play(String name, {pan: 0}){
    var ops = {'pan': pan};
    _soundManager.callMethod('play', [name, new JsObject.jsify(ops)]);
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
