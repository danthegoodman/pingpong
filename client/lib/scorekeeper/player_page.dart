library us.kirchmeier.pingpong.scorekeeper.players;

import 'dart:html';
import 'dart:math';
import 'sc_common.dart';
import 'team_page.dart';
import 'game_page.dart';
import 'package:pingpong/common.dart';

DivElement _playersContainer;
DivElement _beginButton;
DivElement _tournamentBanner;

Set<Player> _selection = new Set<Player>();
StreamController<Player> _playerSelectionChange = new StreamController<Player>.broadcast();

class PlayerPage extends ManagerPage{
  final Element element = query("#playerPage");

  PlayerPage(){
    _playersContainer = query("#players");
    _beginButton = query("#begin");
    _tournamentBanner = query("#tournament");

    PlayerManager.onLoadAll.listen(_onLoadAll);
    _beginButton.onClick.listen(_onBeginClick);
    _playerSelectionChange.stream.listen(_onPlayerSelectionChange);
  }

  void onShow(){
    _beginButton.style.opacity = "0";
    _tournamentBanner.style.opacity = "0";

    var oldSelection = _selection.toList();
    for(Player p in oldSelection){
      _deselectPlayer(p);
    }
  }
}

void _onBeginClick(e){
  if(_selection.length != 4 && _selection.length != 2) return;

  if(_selection.length == 4){
    TeamPage.playerSelection = _selection;
    PageManager.goto(TeamPage);
  } else if(_selection.length == 2){
    var teams = _selection.map((p)=> [p]).toList();

    //Shuffle the sides.
    if(RNG.nextBool()) teams = teams.reversed.toList();

    var newGame = new Game.brandNew();
    newGame.teams = teams;
    if(_hasTournamentMatch()){
      newGame.tournamentId = TOURNAMENT.id;
    }

    GameManager.create(newGame).then((realGame){
      GAME = realGame;
      PageManager.goto(GamePage);
    });
  }
}

void _onPlayerSelectionChange(q){
  bool canBegin = _selection.length == 2 || _selection.length == 4;
  _beginButton.style.opacity = (canBegin ? "1" : "0");

  bool hasTournamentMatch = canBegin && _hasTournamentMatch();
  _tournamentBanner.style.opacity = (hasTournamentMatch ? "1" : "0");
}

void _onLoadAll(q){
  _playersContainer.children.clear();
  var buttons = PlayerManager.models.map((Player p)=> _createPlayerButton(p));
  _playersContainer.children.addAll(buttons.where((e)=> e != null));
}

Element _createPlayerButton(Player p){
  if(!p.active) return null;

  bool selected = false;
  var el = new DivElement();
  el.text = p.name;

  _playerSelectionChange.stream.where((Player p2)=> p == p2).listen((q){
    selected = _selection.contains(p);
    (selected ? el.classes.add : el.classes.remove)('selected');
  });

  el.onClick.listen((q){
    if(selected) _deselectPlayer(p);
    else _selectPlayer(p);
  });

  return el;
}

void _selectPlayer(Player p){
  _selection.add(p);
  _playerSelectionChange.add(p);
}

void _deselectPlayer(Player p){
  _selection.remove(p);
  _playerSelectionChange.add(p);
}

bool _hasTournamentMatch(){
  if(TOURNAMENT == null) return false;
  if(_selection.length != 2) return false;

  var players = TOURNAMENT.players;
  int a = players.indexOf(_selection.first);
  int b = players.indexOf(_selection.last);
  if(a == -1 || b == -1) return false;

  var data = TOURNAMENT.table;
  if(data[a][b].length == 2 || data[b][a].length == 2) return false;
  return true;
}
