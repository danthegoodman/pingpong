library us.kirchmeier.pingpong.config;

import 'dart:html';
import 'dart:json' as json;
import 'package:pingpong/common.dart';

final StreamController<Player> _playerDataChange = new StreamController<Player>.broadcast();

void main(){
  new PlayerInfoSection();
  _playerDataChange.stream.listen((Player p)=>  PlayerManager.save(p));

  var sc = readShortcuts();
  new ShortcutField(0, 0, sc);
  new ShortcutField(0, 1, sc);
  new ShortcutField(1, 0, sc);
  new ShortcutField(1, 1, sc);

  PlayerManager.loadAll();
}

class PlayerInfoSection{
  final SelectElement _players = query("#players");
  final InputElement _name = query("#name");
  final ButtonElement _active = query("#active");

  Player _currentPlayer;

  PlayerInfoSection(){
    PlayerManager.onLoadAll.listen(_onPlayersLoad);
    _players.onChange.listen(_onSelectionChange);
    _name.onChange.listen(_onNameChange);
    _active.onClick.listen(_onActiveClick);
    query("#addNewPlayer").onClick.listen(_onAddNewPlayerClick);
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

Map _SHORTCUTS = {};
class ShortcutField{
  String _name;
  InputElement _el;

  ShortcutField(int team, int ndx, Map savedShortcuts){
    _name = "$team$ndx";
    _el = query("#sc$_name");
    _el.onClick.listen(_onClick);
    _el.onKeyDown.listen(_onKeyDown);

    savedShortcuts.forEach((key, field){
      if(field != _name) return;
      _el.value = key;
      _SHORTCUTS[field] = key;
    });
  }

  _onClick(q){
    _el.focus();
  }

  _onKeyDown(KeyboardEvent e){
    var key = new String.fromCharCode(e.which);
    _el.value = key;
    _SHORTCUTS[_name] = key;
    _saveShortcuts();
  }
}

_saveShortcuts(){
  var sc = {};
  _SHORTCUTS.forEach((name, key){
    sc[key] = name;
  });
  window.localStorage['shortcuts'] = json.stringify(sc);
}
