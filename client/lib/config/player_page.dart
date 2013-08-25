library player_page;

import 'dart:html';
import 'package:pingpong/common.dart';

final StreamController<Player> _playerDataChange = new StreamController<Player>.broadcast();
SelectElement _players;
InputElement _name;
ButtonElement _active;

Player _currentPlayer;

class PlayerPage extends ManagerPage{
  Element element;

  PlayerPage(){
    element = query("#playerSection");
    _players = query("#players");
    _name = query("#name");
    _active = query("#active");

    _playerDataChange.stream.listen((Player p)=>  PlayerManager.save(p));

    _players.onChange.listen(_onSelectionChange);
    _name.onChange.listen(_onNameChange);
    _active.onClick.listen(_onActiveClick);
    query("#addNewPlayer").onClick.listen(_onAddNewPlayerClick);

    PlayerManager.onLoadAll.listen(_onPlayersLoad);
    PlayerManager.loadAll();
  }
}

_onPlayersLoad(q){
  _players.children.clear();
  var models = PlayerManager.models;
  var opts = models.map((p)=> new PlayerOption(p).element);
  _players.children.addAll(opts);
  _players.value = models.first.id;
  _onSelectionChange();
}

_onSelectionChange([q]){
  _currentPlayer = PlayerManager.get(_players.value);
  _name.value = _currentPlayer.name;
  _redrawActiveButton();
}

_redrawActiveButton(){
  _active.text = (_currentPlayer.active ? "Yes" : "No");
}

_onNameChange(q){
  _currentPlayer.name = _name.value;
  _playerDataChange.add(_currentPlayer);
}

_onActiveClick(q){
  _currentPlayer.active = !_currentPlayer.active;
  _redrawActiveButton();
  _playerDataChange.add(_currentPlayer);
}

_onAddNewPlayerClick(q){
  PlayerManager.create(new Player.brandNew()).then((Player p){
    _players.append(new PlayerOption(p).element);
    _players.value = p.id;
    _onSelectionChange();
  });
}

class PlayerOption{
  final OptionElement element = new OptionElement();
  final Player player;

  PlayerOption(this.player){
    element.value = player.id;
    _playerDataChange.stream.where((p)=> p == player).listen(_redraw);
    _redraw();
  }

  _redraw([q]){
    element.text = player.name;
  }
}
