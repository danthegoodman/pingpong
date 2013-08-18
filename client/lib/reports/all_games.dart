library us.kirchmeier.pingpong.reports.all_games;

import 'dart:html';
import "package:pingpong/common.dart";

class AllGamesReport extends ManagerPage{
  final Element element = query("#allGames");
  Map<String, PlayerRow> _players = {};
  bool _loaded = false;

  AllGamesReport(){
    PlayerManager.onLoadAll.listen(_onPlayersLoad);
  }

  void onShow(){
    if(_loaded) return;
    getJSON('/reports/games').then(_onProcessGames);
    getJSON('/reports/points').then(_onProcessPoints);
    _loaded = true;
  }

  void _onPlayersLoad([q]){
    var playerContainer = element.query('.players');
    playerContainer.children.clear();
    PlayerManager.models.forEach((Player p){
      var r = new PlayerRow(p);
      _players[p.id] = r;
      playerContainer.append(r.element);
    });
  }

  void _onProcessGames(Iterable<Map> data){
    for(var d in data){
      var id = d['_id'];
      var val = d['value'];
      _players[id].renderGames(val);
    }
  }

  void _onProcessPoints(Iterable<Map> data){
    for(var d in data){
      var id = d['_id'];
      var val = d['value'];
      _players[id].renderPoints(val);
    }
  }
}

class PlayerRow {
  Element element;

  PlayerRow(Player player){
    element = new TableRowElement();
    element.classes.add('player');
    element.appendHtml("""
      <td class='name'>${player.name}</td>
      <td class='games'></td>
      <td class='win'></td>
      <td class='lose'></td>
      <td class='scoreWon'></td>
      <td class='scoreLost'></td>
      <td class='scoreRatio'></td>
      <td class='serveGood'></td>
      <td class='serveBad'></td>
      <td class='serveRatio'></td>
    """);
  }

  void renderGames(Map m){
    num win = m['win'];
    num lose = m['lose'];
    _setNumText('.games', win + lose);
    _setNumText('.win', win);
    _setNumText('.lose', lose);
  }

  void renderPoints(Map m){
    num scoreWon = m['scoreWon'];
    num scoreLost = m['scoreLost'];
    num serveGood = m['goodServe'];
    num serveBad = m['badServe'];

    _setNumText('.scoreWon', scoreWon);
    _setNumText('.scoreLost', scoreLost);
    _setNumText('.serveGood', serveGood);
    _setNumText('.serveBad', serveBad);

    var scoreRatio = (scoreWon / scoreLost).toStringAsFixed(2);
    element.query('.scoreRatio').text = scoreRatio;

    var serveRatio = (serveGood / (serveGood + serveBad))*100;
    var sr = serveRatio.toStringAsFixed(2);
    element.query('.serveRatio').text = "$sr%";
  }

  _setNumText(String css, dynamic n){
    element.query(css).text = n.toStringAsFixed(0);
  }
}
