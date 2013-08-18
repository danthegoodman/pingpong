library us.kirchmeier.pingpong.createTournament;

import 'dart:html';
import 'package:pingpong/common.dart';

Map TOURNAMENT_TYPES = {
  "ROUND_ROBIN": 'Round Robin',
};

Set<Player> _selectedPlayers = new Set<Player>();
TextInputElement _title;
SelectElement _type;

void main(){
  _type = query("#type");
  _title = query("#title");

  PlayerManager.loadAll().then((q){
    query("#players").children.addAll(PlayerManager.models.map((p)=> _createPlayerButton(p)));
  });
  TOURNAMENT_TYPES.forEach((value, name){
    _type.append(new OptionElement(name, value));
  });

  query("#create").onClick.listen(_onCreateClick);
}

void _onCreateClick(q){
  var title = _title.value;
  if(title.isEmpty){
    window.alert("A title is required");
    return;
  }

  var t = new Tournament.brandNew()
      ..players = (_selectedPlayers.toList()..sort())
      ..type = _type.value
      ..title = title;

  _constructTable(t);

  TournamentManager.create(t).then((q){
    window.alert("The tournament has been created!");
    window.location.assign("/index");
  });
}

Element _createPlayerButton(Player p){
  var el = new DivElement()
    ..classes.add('player')
    ..text = p.name;
  el.onClick.listen((q){
    if(_selectedPlayers.contains(p)){
      _selectedPlayers.remove(p);
      el.classes.remove('selected');
    } else {
      _selectedPlayers.add(p);
      el.classes.add('selected');
    }
  });
  return el;
}

void _constructTable(Tournament t){
  if(t.type == "ROUND_ROBIN"){
    _constructRoundRobinTable(t);
  }
}

///2D grid of lists of game won.
///
/// `grid[x][y]` : games won by X against Y
/// `grid[y][x]` : games won by Y against X
void _constructRoundRobinTable(Tournament t){
  int length = t.players.length;
  var data = new List.generate(length, (n)=> new List.generate(length, (m)=>[]));
  t.table = data;
}